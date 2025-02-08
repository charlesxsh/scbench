import re
from typing import Dict, List, Set, Tuple
from slither.core.declarations import Contract, FunctionContract, SolidityFunction
import string
import random
from slither.core.variables.state_variable import StateVariable
from typing import Dict, List
from slither.core.declarations import Contract, FunctionContract, SolidityFunction
from slither.slithir.operations import InternalCall, LibraryCall, EventCall, Operation, HighLevelCall, Return
from slither.core.cfg.node import NodeType, Node
import logging

logger = logging.getLogger(__name__)

def generate_random_string(length):
    letters = (
        string.ascii_letters + string.digits
    )  # includes both uppercase and lowercase letters, and digits
    result = "".join(random.choice(letters) for _ in range(length))
    return result


def find_all_callees(funcs: Set[FunctionContract]) -> Set[FunctionContract]:
    to_explore: List[FunctionContract] = []
    explored: Set[FunctionContract] = set()

    for f in funcs:
        to_explore.append(f)

    while len(to_explore) != 0:
        f = to_explore.pop(0)
        if f is None or f in explored:
            continue
        explored.add(f)
        if hasattr(f, "is_constructor") and f.is_constructor:
            to_explore.extend(f.contract.constructors)

        if isinstance(f, SolidityFunction):
            continue
        for c in f.all_internal_calls():
            to_explore.append(c)
        for c in f.all_library_calls():
            callee = c[1]
            to_explore.append(callee)

    return explored

def slice(initf: FunctionContract, params: List[int] = None, 
          msg_sender=False, actions:List[str] = None, reverse=False,
          only_callees:List[str]=None) -> Set[int]:
    """Slice a given function(and its related callees)

    Args:
        initf (FunctionContract): _description_
        params (List[int], optional): _description_. Defaults to None.
        msg_sender (bool, optional): _description_. Defaults to False.
        actions (List[str], optional): _description_. Defaults to None.
        reverse (bool, optional): _description_. Defaults to False.

    Returns:
        Set[int]: _description_
    """
    logger.debug(f"slice function={initf.name} from {initf.contract.name}/{initf.contract_declarer.name}, params={params}, msg_sender={msg_sender}, actions={actions}, reverse={reverse}")
    relevant_lines = set()
    
    if params or msg_sender is True or actions or reverse is True:
        normal_slice = False
    else:
        normal_slice = True

    fn2cared = {}
    fn2cared[initf] = set()
    fn2params = {}
    fn2params[initf] = params
    to_explore: List[FunctionContract] = [initf]
    explored: Set[FunctionContract] = set()
    dirty_fns:Set[FunctionContract] = set()
    
    # minimal req: function's signature is needed
    dirty_fns.add(initf)
    dirty_state_vars = set()
    
    matched_lines = set()
    cond_callsite_lines: Dict[Operation, FunctionContract] = {}
    cond_sv: Set[Tuple[Node, StateVariable]] = set()
    while len(to_explore) != 0:
        f = to_explore.pop(0)
        if f is None or f in explored:
            continue
        explored.add(f)
        if f not in fn2cared:
            fn2cared[f] = set()
        
        fparams = fn2params.get(f, None)
        if fparams:
            for param_index in fparams:
                if param_index < len(f.parameters):
                    fn2cared[f].add(f.parameters[param_index])
        
        if hasattr(f, "is_constructor") and f.is_constructor:
            to_explore.extend(f.contract.constructors)
        if isinstance(f, SolidityFunction):
            continue

        cared_vars = fn2cared[f]
        for node in f.nodes:
            # logger.debug(f"{node.type},{node}")
            need_node = False
            has_cared_vars = False
            has_emit = False
            callees:List[str] = []
            
            if node.calls_as_expression:
                for ir in node.irs:
                    if isinstance(ir, EventCall):
                        has_emit = True
                    elif isinstance(ir, HighLevelCall):
                        callees.append(ir.function.name)
                    elif isinstance(ir, InternalCall) or isinstance(ir, LibraryCall):
                        callee = ir.function
                        callees.append(callee.name)

                        if msg_sender:
                            has_msg_sender = ("msg.sender" in [var.name for var in ir.function.return_values])
                            if has_msg_sender:
                                # The return value(lvalue) of the call that return msg.sender is also the msg.sender
                                cared_vars.add(ir.lvalue)
                                cond_callsite_lines[ir] = callee

                        # add corresponding function parameters to fn2params
                        # which will be added to fn2cared later when processing that function
                        if any([var in ir.arguments for var in cared_vars]):
                           
                            if callee not in fn2params:
                                fn2params[callee] = []
                            callee_params = fn2params[callee] 
                            callee_params.extend([idx for idx, arg in enumerate(ir.arguments) if arg in cared_vars])

                        to_explore.append(callee)
                        cond_callsite_lines[ir] = callee
                     
            for var in cared_vars:
                if var in node.variables_read or var in node.variables_written:
                    has_cared_vars = True
                    break

            if msg_sender and "msg.sender" in [var.name for var in node.variables_read if var is not None]:
                has_cared_vars = True
            
            cared_vars_check = ((params or msg_sender) and has_cared_vars) or (not params and not msg_sender)
            if actions is not None:
                has_cared_action = False
                if "throw" in actions:
                    if node.type == NodeType.THROW:
                        has_cared_action = True
                        cared_vars_check = True

                    if node.contains_require_or_assert():
                        has_cared_action = True
                if "emit" in actions:
                    if has_emit:
                        has_cared_action = True
                if "return" in actions:
                    if node.type == NodeType.RETURN:
                        has_cared_action = True
                        # make sure return node is needed if action contains return
                        cared_vars_check = True
                if  "call" in actions:
                    if callees:
                        if only_callees:
                            for oc in only_callees:
                                if oc in callees:
                                    has_cared_action = True
                        else:
                            has_cared_action = True
                if "assign" in actions:
                    if node.state_variables_written:
                        has_cared_action = True
                need_node = has_cared_action and cared_vars_check
            else:
                need_node = cared_vars_check
            
            if need_node and reverse:
                need_node = not need_node

            # if need_node:
            #     for l in node.source_mapping.lines:
            #         matched_lines.add(l)
            # if reverse:
            #     need_node = not need_node
            if need_node or normal_slice:
                for l in node.source_mapping.lines:
                    relevant_lines.add(l)
                    
                dirty_fns.add(f)

                for sv in node.state_variables_read:
                    dirty_state_vars.add(sv)
                    cond_sv.add((node, sv))
                for sv in node.state_variables_written:
                    dirty_state_vars.add(sv)
                    cond_sv.add((node, sv))
        
        # handle conditional callsite
        for callsite_op, callee in cond_callsite_lines.items():
            lines_set = set(callee.source_mapping.lines)
            callsite_set = set(callsite_op.node.source_mapping.lines)
            for rl in relevant_lines:
                if rl in lines_set:
                    for l in callsite_set:
                        relevant_lines.add(l)
                    dirty_fns.add(callsite_op.node.function)
                    break
                elif rl in callsite_set:
                    dirty_fns.add(callee)
                    break

        # handle block
        if_start_node = {}
        cnt = 0
        for node in f.nodes:
            if node.type == NodeType.IF:
                if_start_node[min(node.source_mapping.lines)] = node
                cnt += 1
            if node.type == NodeType.ENDIF:
                cnt -= 1
        # not sure it is bug or not
        # if 'else block' only has return, no ENDIF node will exist
        if cnt != 0:
            lines = f.source_mapping.content.splitlines()
            offsets = f.source_mapping.lines
            offset = min(offsets)
            for i, line in enumerate(lines):
                line = line.strip()
                need_line = False
                if line.startswith("if"):
                    need_line = True
                    for j in range(offset+i, max(f.source_mapping.lines)):
                        if j in if_start_node:
                            start_node = if_start_node[j]
                            break
                    for k in start_node.source_mapping.lines:
                        relevant_lines.add(k)

                elif line.startswith("}") or line.find("else") != -1:
                    need_line = True
                if need_line:
                    relevant_lines.add(offset+i)

        # loop to add if block until no new if block is added
        changed = True
        added_if = set()
        while changed:
            changed = False

            for node in f.nodes:

                if node.type == NodeType.ENDIF:
                    start_at = min(node.source_mapping.lines) 
                    start_node = None
                    for i in range(start_at, max(node.source_mapping.lines)+1):
                        if i in if_start_node:
                            start_node = if_start_node[i]
                            break
                    
                    block_lines = set(node.source_mapping.lines)
                    if block_lines & relevant_lines:
                        if start_at not in added_if:
                            added_if.add(start_at)
                            changed = True

                            # add block start and end
                            for l in start_node.source_mapping.lines:
                                relevant_lines.add(l)
                            
                            relevant_lines.add(max(node.source_mapping.lines))
                    # for line in relevant_lines:
                    #     if line in block_lines: 
                    #         if start_at not in added_if:
                    #             added_if.add(start_at)
                    #             changed = True

                    #             # add block start and end
                    #             for l in start_node.source_mapping.lines:
                    #                 relevant_lines.add(l)
                                
                    #             relevant_lines.add(max(node.source_mapping.lines))
                    #             break
    # handle state variable that required
    for node, sv in cond_sv:
        if set(node.source_mapping.lines) & relevant_lines:
            relevant_lines = relevant_lines | set(sv.source_mapping.lines)

    dirty_contracts:Set[Contract] = set()
    # add function declaration block start and end lines
    for f in dirty_fns:
        
        # check if the function is an empty(not even one line in its body exists in the relevant_lines)
        fbody = set(f.source_mapping.lines)
        if not f == initf and not any([l in fbody for l in relevant_lines]):
            continue
        fstart = min(f.source_mapping.lines)
        lines = f.source_mapping.content.splitlines()

        # if function declaration has multiple lines
        for i, line in enumerate(lines):
            relevant_lines.add(fstart+i)
            if line.strip().endswith("{"):
                break
        fend = max(f.source_mapping.lines)
        relevant_lines.add(fstart)
        relevant_lines.add(fend)
        dirty_contracts.add(f.contract_declarer)
    
    # add contract declaration block start and end
    for c in dirty_contracts:
        fstart = min(c.source_mapping.lines)
        lines = c.source_mapping.content.splitlines()

        # if function declaration has multiple lines
        for i, line in enumerate(lines):
            relevant_lines.add(fstart+i)
            if line.strip().endswith("{"):
                break
        fend = max(c.source_mapping.lines)
        relevant_lines.add(fend)
    
    
    return relevant_lines

def slithir_funcs_to_text(
    funcs: Set[FunctionContract],
    filelines: List[str],
    with_comment=True,
    lstrip=False,
    with_contract_decl=False,
    with_state_var=False,
    mangle_localvar=False,
    mangle_statevar=False,
) -> str:
    explored_start_lines = set()

    # contract line regions, contract => array of (line/block string, line/block start number)
    # line number is used to sort the order
    contract2lines: Dict[Contract, List[Tuple[str, int]]] = {}

    # mapping from state variable and mangled name
    contract_state_var_replace_map: Dict[StateVariable, str] = {}

    for func in funcs:
        if not func.source_mapping or not func.source_mapping.lines:
            # require, assert, etc..
            continue
        func_start_line = min(func.source_mapping.lines)
        if func_start_line in explored_start_lines:
            continue
        explored_start_lines.add(func_start_line)

        # make sure func belong to same contract are stick together
        if func.contract_declarer not in contract2lines:
            contract2lines[func.contract_declarer] = []

        lines: List = contract2lines[func.contract_declarer]

        func_begin_at_index = len(lines)
        # extract function body
        func_body_end = max(func.source_mapping.lines)

        func_lines: List[str] = []
        replace_map = {}
        if mangle_localvar:
            for v in func.local_variables:
                replace_map[v.name] = generate_random_string(random.randint(4, 10))
            for v in func.parameters:
                replace_map[v.name] = generate_random_string(random.randint(4, 10))

        for line_id in range(func_start_line, func_body_end + 1):
            line = filelines[line_id - 1]
            if lstrip:
                line = line.lstrip()
            if line.strip().startswith(("*", "/*", "//")) and not with_comment:
                continue

            if mangle_localvar:
                for key, value in replace_map.items():
                    line = re.sub(f"\\b{key}\\b", value, line)
                    # line = re.sub(f"`{key}`", '`'+value+'`', line)
            func_lines.append((line, line_id - 1))

        if mangle_statevar:
            state_vars = set(func.state_variables_read) | set(
                func.state_variables_written
            )
            for v in state_vars:
                if v not in contract_state_var_replace_map:
                    contract_state_var_replace_map[v] = generate_random_string(
                        random.randint(4, 10)
                    )

            replaced_lines = []
            for line, row in func_lines:
                for v in state_vars:
                    line = re.sub(
                        f"\\b{v.name}\\b", contract_state_var_replace_map[v], line
                    )
                replaced_lines.append((line, row))

            func_lines = replaced_lines

        lines.extend(func_lines)

        # extract function's comment if any
        if with_comment:
            if func.source_mapping.lines:
                curr = func_start_line - 2
                while curr >= 0:
                    curr_line = filelines[curr]
                    if curr_line == "\n" or curr_line.strip().startswith(
                        ("*", "/*", "//")
                    ):
                        curr -= 1
                        if lstrip:
                            curr_line = curr_line.lstrip()

                        for key, value in replace_map.items():
                            curr_line = re.sub(f"\\b{key}\\b", value, curr_line)
                        lines.append((curr_line, curr))
                    else:
                        break

        # add contract decl and state variable if any
        if with_state_var and not with_contract_decl:
            with_contract_decl = True

        if with_state_var:
            state_vars = set(func.state_variables_read) | set(
                func.state_variables_written
            )
            for v in state_vars:
                start_line = min(v.source_mapping.lines)
                if start_line in explored_start_lines:
                    continue
                explored_start_lines.add(start_line)

                # handle state variable decleration here
                if v.contract not in contract2lines:
                    contract2lines[v.contract] = []
                target_region = contract2lines[v.contract]

                for idx in v.source_mapping.lines:
                    # target_region.insert(0, filelines[idx - 1])
                    target_region.append((filelines[idx - 1], idx - 1))

                if with_comment:
                    if v.source_mapping.lines:
                        curr = start_line - 2
                        while curr >= 0:
                            curr_line = filelines[curr]
                            if curr_line == "\n" or curr_line.strip().startswith(
                                ("*", "/*", "//")
                            ):
                                curr -= 1
                                if lstrip:
                                    curr_line = curr_line.lstrip()
                                # since we put state variable at the beginning
                                # the comment with it should also at the beginning
                                target_region.append((curr_line, curr))
                            else:
                                break

    text = ""
    for c, strs in contract2lines.items():
        # put the start of contract decleration if flag is on
        if with_contract_decl:
            start_line_idx = min(c.source_mapping.lines)
            decl_start_lines = []
            line_idx = start_line_idx
            while line_idx <= len(filelines):
                line = filelines[line_idx - 1]
                decl_start_lines.append(line)
                line_idx += 1
                if line.rstrip().endswith("{"):
                    break
            text += "".join(decl_start_lines)
        sorted_tuples = sorted(strs, key=lambda t: t[1])
        sorted_lines = map(lambda t: t[0], sorted_tuples)
        text += "".join(sorted_lines)

        # put the end of contract decleration to the end if flag is on
        if with_contract_decl:
            end = max(c.source_mapping.lines)
            if end - 1 >= len(filelines):
                text += filelines[len(filelines) - 1]
            else:
                text += filelines[end - 1]
        text += "\n"

    return text








