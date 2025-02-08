from dataclasses import asdict, dataclass
import json
import random
from typing import List, Optional, Tuple
from slither.slither import Slither, SlitherCompilationUnit
from slither.core.declarations import Contract, FunctionContract
from slither.slithir.operations import Return, Assignment, HighLevelCall, EventCall
from sol.utils import find_throw_nodes, get_anchored_state_variable, get_contracts_and_ercs, get_function_body_range, get_the_function, compile
from slither.core.solidity_types.elementary_type import ElementaryType
from llm.adapters import OpenAILLMAdapter
from errinj.erc_inject_configs import erc_error_injector_configs
import os
import logging
logger = logging.getLogger(__name__)

@dataclass
class ChangeLog:
    orig_range: Tuple[int, int]
    to_replace: List[str]
    
    def __hash__(self):
        return hash(self.orig_range)

    def __eq__(self, other):
        if isinstance(other, ChangeLog):
            return self.orig_range == other.orig_range
        return False

    def __ne__(self, other):
        return not self.__eq__(other)

def apply_changelog(lines: List[str], changelogs: List[ChangeLog]) -> List[str]:
    # Create a copy of the lines to avoid modifying the original list
    modified_lines = lines.copy()
    
    # Sort the changelog by the starting index of the range
    changelogs = sorted(list(set(changelogs)), key=lambda x: x.orig_range[0])
    
    if len(changelogs) > 1:
        new_changelogs = []
        i = 0
        while i < len(changelogs)-1:
            cl_l = changelogs[i]
            cl_r = changelogs[i+1]
            if cl_r.orig_range[0] <= cl_l.orig_range[1]:
                # has overlap or continues
                merged_replace = []
                merged_replace.extend(cl_l.to_replace)
                merged_replace.extend(cl_r.to_replace)
                new_changelogs.append(ChangeLog(
                    orig_range=(cl_l.orig_range[0], cl_r.orig_range[1]),
                    to_replace=merged_replace
                ))
                i += 1 # eat the next
            else:
                new_changelogs.append(changelogs[i])
            i += 1
        if i == len(changelogs)-1:
            new_changelogs.append(changelogs[i])
        changelogs = new_changelogs
    delta = 0  # Track the change in line count
    print(changelogs)
    for change in changelogs:
        start, end = change.orig_range
        adjusted_start = start + delta
        adjusted_end = end + delta
        
        # Calculate the difference in lengths
        orig_length = end - start + 1
        new_length = len(change.to_replace)
        length_difference = new_length - orig_length
        
        # Apply the change
        print(modified_lines[adjusted_start-1:adjusted_end], change.to_replace)
        modified_lines[adjusted_start-1:adjusted_end] = change.to_replace
        
        # Update delta
        delta += length_difference
    
    return modified_lines
    

@dataclass
class InjectContext:
    cu: SlitherCompilationUnit
    target_fn: Optional[FunctionContract]
    contract: Optional[Contract]
    lines: List[str]

def inject_throw_error(ctx: InjectContext, strategy:int, 
                       related_fn_params:List[int]=None, msgsender=None, 
                       wr:int = None) -> List[ChangeLog]:
    """_summary_

    Args:
        ctx (InjectContext): _description_
        strategy (int): _description_

    Returns:
        List[ChangeLog]: _description_
    """
    change_logs = []
    nodes = find_throw_nodes(ctx.target_fn, related_fn_params, msgsender)
    for node in nodes:
        lines = node.source_mapping.lines
        change_logs.append(
            ChangeLog(orig_range=(min(lines), max(lines)), to_replace=[])
        )
    if wr == 1:
        flines = ctx.target_fn.source_mapping.lines
        body_start, body_end = get_function_body_range(ctx.lines, min(flines), max(flines))
        i = body_start
        rm_start = None
        rm_end = None
        while i <= body_end:
            if ctx.lines[i-1].find("approve(") != -1 or ctx.lines[i-1].find("spendAllowance(") != -1:
                rm_start = i
            elif ctx.lines[i-1].strip(" \n").endswith(";") and  rm_start is not None:
                rm_end = i
                break
            i += 1
        if rm_start is not None and rm_end is not None:
            change_logs.append(
                ChangeLog(orig_range=(rm_start, rm_end), to_replace=[])
            )

    return change_logs

def inject_emit_error(ctx: InjectContext, strategy:int, event_name:str, state_var_anchor_fn:str) -> Tuple[List[ChangeLog], str]:
    """Inject errors related to emit

    Args:
        ctx (InjectContext): _description_
        strategy (int): _description_
        contract (str): _description_
        function (str): _description_

    Returns:
        List[ChangeLog]: _description_
    """
    change_logs = []
    
    # Fn is None is the rule is function-related emit
    # Fn is not None, and will be a public function name if the fule is compound-rule
    fn = None
    if ctx.target_fn is not None:
        # means it is function related emit
        ev_calls = [op for op in ctx.target_fn.all_slithir_operations() if isinstance(op, EventCall) and op.name == event_name]
        for call in ev_calls:
            lines = call.node.source_mapping.lines
            change_logs.append(
                ChangeLog(orig_range=(min(lines), max(lines)), to_replace=[])
            )
        
    else:
        # means it is comppund-rule, we need to pick a function that has such state var changed
        anchor_fn = get_the_function(ctx.cu, ctx.contract, fname=state_var_anchor_fn)
        anchored_statevar = get_anchored_state_variable(anchor_fn)
        potential_fns = [f for f in ctx.contract.functions if (f.is_constructor or f.visibility == "public") and anchored_statevar in f.all_state_variables_written()]
        if not potential_fns:
            return None
        target_fn = potential_fns[0]
        fn = target_fn.name
        ev_calls = [op for op in target_fn.all_slithir_operations() if isinstance(op, EventCall) and op.name == event_name]
        for call in ev_calls:
            lines = call.node.source_mapping.lines
            change_logs.append(
                ChangeLog(orig_range=(min(lines), max(lines)), to_replace=[])
            )
        
    return change_logs, fn

def inject_call_error(ctx: InjectContext, strategy:int, expect_call_fn:str) -> List[ChangeLog]:
    """_summary_

    Args:
        ctx (InjectContext): _description_
    Returns:
        List[ChangeLog]: _description_
    """
    change_logs = []
    for node in ctx.target_fn.all_nodes():
        for ir in node.irs:
            if isinstance(ir, HighLevelCall):
                if ir.function.name == expect_call_fn:
                    flines = node.function.source_mapping.lines
                    start, end = get_function_body_range(ctx.lines, min(flines),  max(flines))
                    content = ""
                    ret_ty = node.function.return_type
                    if ret_ty:
                        ret_ty = ret_ty[0]
                    if str(ret_ty) == "bool":
                        content += "    return true;"

                    change_logs.append(
                        ChangeLog(orig_range=(start, end), to_replace=[content])
                    )
    return change_logs

def inject_assign_error(ctx: InjectContext, strategy:int, state_var_anchor_fn:str) -> List[ChangeLog]:
    """Inject errors related to assign.
    
    strategies:
    1. remove the assignment (done)
    2. replace operation

    Args:
        ctx (InjectContext): _description_
        strategy (int): _description_
        contract (str): _description_
        function (str): _description_

    Returns:
        List[ChangeLog]: _description_
    """
    anchor_fn = get_the_function(ctx.cu, ctx.target_fn.contract.name, fname=state_var_anchor_fn)
    anchored_statevar = get_anchored_state_variable(anchor_fn)
    assign_ops = [op for op in ctx.target_fn.all_slithir_operations() if isinstance(op, Assignment)]
    change_logs = []
    for op in assign_ops:
        if str(op).find(anchored_statevar.name) != -1:
            lines = op.node.source_mapping.lines
            change_logs.append(
                ChangeLog(orig_range=(min(lines), max(lines)), to_replace=[])
            )
    return change_logs

def inject_interface_error(ctx: InjectContext, strategy:int) -> List[ChangeLog]:
    """Remove the public function
    
    1. remove the whole function body + interface(if any)
   

    Args:
        ctx (InjectContext): _description_
        strategy (int): _description_

    Returns:
        List[ChangeLog]: _description_
    """
    change_logs = []
    lines = ctx.target_fn.source_mapping.lines
    change_logs.append(ChangeLog(orig_range=(min(lines), max(lines)), to_replace=[]))
    
    # remove parent or interface as well
    for func in ctx.target_fn.contract.functions:
        if func.name == ctx.target_fn.name and \
            len(func.parameters) == len(ctx.target_fn.parameters): 
                lines = func.source_mapping.lines
                change_logs.append(ChangeLog(orig_range=(min(lines), max(lines)), to_replace=[]))

    return list(set(change_logs))
    
    

def inject_return_error(ctx: InjectContext, strategy:int) -> List[ChangeLog]:
    """Inject error related to return
    
    Strategies:
    1. same type, but wrong value
        - ex. revert boolean, add not before the return value
        - ex. integer type, incorrect value + (1, 1000)
        - ex. string, ""
    2. different type

    Args:
    
        strategy (int): _description_
        contract (str): _description_
        function (SolidityFunctionFormat): _description_

    Returns:
        str: _description_
    """
    target_fn = ctx.target_fn
    return_type:str = target_fn.return_type[0].type
    return_lines = []
    for op in ctx.target_fn.all_slithir_operations():
        if isinstance(op, Return):
            if op.node.function == target_fn:
                return_lines.append(op.node.source_mapping.lines[0])
    change_logs = []
    if return_type == "bool":
        for rline in return_lines:
            orig_line = ctx.lines[rline-1]
            if orig_line.find("false") != -1:
                to_replace = f"{orig_line}"
                to_replace = to_replace.replace("false", "true")
            elif orig_line.find("true") != -1:
                to_replace = f"{orig_line}"
                to_replace = to_replace.replace("true", "false")
            else:
                return_after = orig_line.find("return")
                to_replace = orig_line[:return_after+7] + "!" + orig_line[return_after+7:]

            cl = ChangeLog(orig_range=(rline, rline), to_replace=[to_replace])
            change_logs.append(cl)
    
    elif return_type.startswith("uint"):
        for rline in return_lines:
            orig_line = ctx.lines[rline-1]
            before_end = orig_line.find(";")
            rand_num = random.randint(1, 1000) if return_type != "uint8" else 3
            new_line = orig_line[:before_end] + f"+{rand_num};"
            cl = ChangeLog(orig_range=(rline, rline), to_replace=[new_line])
            change_logs.append(cl)
    elif return_type == "string":
        for rline in return_lines:
            orig_line = ctx.lines[rline-1]
            after_ret = orig_line.find("return ")
            new_line = orig_line[:after_ret+7] + "\"\";"
            cl = ChangeLog(orig_range=(rline, rline), to_replace=[new_line])
            change_logs.append(cl)
    elif return_type == "address":
        for rline in return_lines:
            orig_line = ctx.lines[rline-1]
            after_ret = orig_line.find("return ")
            new_line = orig_line[:after_ret+7] + f"address({random.randint(1, 1000)});"
            cl = ChangeLog(orig_range=(rline, rline), to_replace=[new_line])
            change_logs.append(cl)
        
    else:
        logger.error(f"does not have strategy for injecting error to type {return_type}")
    return change_logs

def audit(code: str, rule:str, contract:str, function:str, llm_adapter: OpenAILLMAdapter) -> bool:
    prompt = f"""Whether the following smart contract {contract} violate ERC rule {rule} {("for function "+function) if function else ""}? Answer YES or NO.
            Code:\"\"\"
            {code}
            \"\"\"
            """
    res = llm_adapter.ask([{"content": prompt, "role":"user"}], temperature=0, n=1)[0]
    return res.find("YES") != -1


def fix(code: str, llm_adapter: OpenAILLMAdapter) -> bool:
    prompt = f"""The following smart contract violate ERC20 rules. Can you modify the code to make it consistent with ERC20 rules without changing the funtionality? Answer YES or NO. If YES, return the fixed code.
            Code:\"\"\"
            {code}
            \"\"\"
            """
    res = llm_adapter.ask([{"content": prompt, "role":"user"}], temperature=0, n=1)[0]
    return res.find("YES") != -1


def inject_err_to_contract(erc_file, out, num_of_errors=3):
    _, cu = compile(erc_file)
      
    # prepare the file lines
    with open(erc_file, "r") as f:
        lines = f.read().splitlines(True)
   
    erc_file_name = os.path.basename(erc_file).split(".")[0]
    # get the contract(s) without been inherited and their erc(s)
    c2ercs = get_contracts_and_ercs(cu)

    # only one contract without inheritance exist
    contract, ercs = list(c2ercs.items())[0]
    metadata_json = os.path.join(out, erc_file_name+".json")
    
    erc = None
    
    if "721" in ercs:
        erc = "721"
    elif "1155" in ercs:
        erc = "1155"
    elif "20" in ercs:
        erc = "20"
    if erc is None:
        return
    
    if os.path.exists(metadata_json):
        with open(metadata_json, "r") as mf:
            existing_meta = json.load(mf)
        if existing_meta['erc'] == erc:
            return
    
   
    inj_configs = erc_error_injector_configs[erc]
    
    # randomly choose N config
    selected_inj_configs = []
    randomlist = random.sample(range(len(inj_configs)), num_of_errors)
    for index in randomlist:
        selected_inj_configs.append(inj_configs[index])

    err_file = os.path.join(out, f"{erc_file_name}.sol")
    metadata = {
        "erc": erc,
        "contract": contract.name,
        "inj_file": err_file,
        "orig_file": erc_file,
        "inj_errors": [],
        "compile_error": None
    }
    all_change_logs = []
    for i, inj_config in enumerate(selected_inj_configs):
        logger.info(inj_config)
        inj_type = inj_config[0]
        inj_args = inj_config[1]
        changelogs = None
        target_fn = None
        if "function" in inj_args:
            target_fn = get_the_function(cu, contract.name, fname=inj_args["function"], fnumofargs=inj_args["numofargs"])
        inj_ctx = InjectContext(
            cu=cu,
            target_fn=target_fn,
            contract=contract,
            lines=lines
        )
        inj_ex = None
        try:
            if inj_type == "throw":
                changelogs = inject_throw_error(inj_ctx, 0, inj_args.get('fn_params', None), inj_args.get('msgsender', None), inj_args.get('wr', None))
            elif inj_type == "emit":
                changelogs = inject_emit_error(inj_ctx, 0, inj_args['event'], inj_args.get('anchor_fn', None))
            elif inj_type == "call":
                changelogs = inject_call_error(inj_ctx, 0, inj_args['callee'])
            elif inj_type == "assign":
                changelogs = inject_assign_error(inj_ctx, 0, inj_args['anchor_fn'])
            elif inj_type == "interface":
                changelogs = inject_interface_error(inj_ctx, 0)
            elif inj_type == "return":
                changelogs = inject_return_error(inj_ctx, 0)
        except Exception as ex:
            logger.error(ex, stack_info=True, exc_info=True)
            inj_ex = str(ex)
            

        if changelogs is None:
            logger.error("changelogs is none")
            continue
        
        all_change_logs.extend(changelogs)
        
        record = {
            "config": inj_config,
            "lines": [asdict(cl) for cl in changelogs]
        }
        metadata["inj_errors"].append(record)
    

    if all_change_logs:
        logger.debug(all_change_logs)
        new_lines = apply_changelog(lines, all_change_logs)
        with open(err_file, "w") as out_file:
            out_file.write("".join(new_lines))
        # call compile function(example at the first line of this function) to see whether it can compile
        try:
            _, _ = compile(err_file)
        except Exception as e:
            # logger.error(e, stack_info=True, exc_info=True)
            inj_ex = "compile error "+ str(e)
        metadata["compile_error"] = inj_ex

    with open(metadata_json, "w") as out_file:
        json.dump(metadata, out_file, indent=4)


