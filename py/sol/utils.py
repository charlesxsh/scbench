

import re
import subprocess
from typing import List, Set
from sol.types import EventArgType, FunctionArgType, SolidityEventFormat, SolidityFunctionFormat
from typing import Dict, List, Tuple, TypedDict
from slither.slither import Slither, SlitherCompilationUnit
from slither.core.declarations import Contract, FunctionContract, SolidityFunction
from slither.core.variables import StateVariable, LocalVariable
from slither.slithir.variables import ReferenceVariable
from slither.core.expressions import CallExpression
from slither.slithir.operations import InternalCall, LibraryCall, EventCall, Operation, HighLevelCall, Return, Assignment, Index
from slither.core.cfg.node import NodeType, Node
import logging
logger = logging.getLogger(__name__)

def parse_function_signature(signature: str) -> SolidityFunctionFormat:
    import re

    # Regular expression to parse Solidity function signature
    pattern = r'function\s+(\w+)\s*\((.*?)\)\s*(public|external)?\s*(view|pure)?\s*(payable)?\s*(returns\s*\(.*\))?\s*'
    match = re.match(pattern, signature.strip())

    if not match:
        print(signature)
        raise ValueError(f"Invalid function signature: '{signature}'")

    function_name = match.group(1)
    args = match.group(2)
    visibility = match.group(3)
    state_modifier = match.group(4)
    is_payable = match.group(5)
    return_type = match.group(6)

    arg_types = []
    if args:
        for arg in args.split(','):
            arg_parts = arg.strip().split(' ')
            if len(arg_parts) >= 2:
                arg_name = arg_parts[-1]
                arg_type = ' '.join(arg_parts[:-1])
                arg_types.append(FunctionArgType(name=arg_name, type=arg_type))
            else:
                raise ValueError(f"Invalid argument in function signature: {arg}")
    ret_type = None
    if return_type:
        return_type = return_type.replace("returns", "")
        ret_parts = return_type.strip().split(' ')
        if len(ret_parts) >= 2:
            arg_name = ret_parts[-1].strip()
            arg_type = ' '.join(ret_parts[:-1]).strip()
            if arg_name.endswith(")"):
                arg_name = arg_name[:-1]
            if arg_type.startswith("("):
                arg_type = arg_type[1:]
            ret_type = FunctionArgType(name=arg_name, type=arg_type)
        else:
            arg_type = ret_parts[0].strip()
            if arg_type.endswith(")"):
                arg_type = arg_type[:-1]
            if arg_type.startswith("("):
                arg_type = arg_type[1:]
                
            ret_type = FunctionArgType(type=arg_type)
    return SolidityFunctionFormat(
        name=function_name,
        arg_types=arg_types,
        optional=None,
        view=state_modifier == 'view',
        pure=state_modifier == 'pure',
        payable=is_payable is not None,
        return_type=ret_type
    )

def parse_event_declaration(declaration: str) -> SolidityEventFormat:
    import re

    # Regular expression to parse Solidity event declaration
    pattern = r'event\s+(\w+)\((.*?)\)'
    match = re.match(pattern, declaration.strip())

    if not match:
        raise ValueError("Invalid event declaration")

    event_name = match.group(1)
    args = match.group(2)

    arg_types = []
    if args:
        for arg in args.split(','):
            arg_parts = arg.strip().split(' ')
            if len(arg_parts) == 3 and arg_parts[1] == 'indexed':
                arg_type, _, arg_name = arg_parts
                indexed = True
            else:
                arg_type, arg_name = arg_parts
                indexed = False

            arg_types.append(EventArgType(name=arg_name, type=arg_type, indexed=indexed))

    return SolidityEventFormat(
        name=event_name,
        arg_types=arg_types
    )
    

def get_event_interface_with_pname(event_name: str, event_params: List) -> str:

    # Constructing the interface string
    interface_string = f"event {event_name}("
    param_strings = [f"{param['type']}{' indexed' if param.get('indexed') else ''} {param['name']}" for param in event_params]
    interface_string += ", ".join(param_strings) + ");"

    return interface_string

def get_event_interface(event_name: str, event_params: List) -> str:

    # Constructing the interface string
    interface_string = f"event {event_name}("
    param_strings = [f"{param['type']}{' indexed' if param.get('indexed') else ''}" for param in event_params]
    interface_string += ", ".join(param_strings) + ");"

    return interface_string


def get_function_signature(fname:str, farg_types, fret):
    return (
                f"{fname}({','.join(farg_types)}) returns({fret})"
                if fret
                else f"{fname}({','.join(farg_types)}) returns()"
            )

def get_contract_names(c: Contract) -> Set[str]:
    """A contract can inherit many other contracts,
    get_contract_names returns a list of names
    for all of them including itself.

    Args:
        c (Contract): Target contract

    Returns:
        Set[str]: list of contract names
    """

    names = set()
    explore = [c]
    explored = set()
    while len(explore) != 0:
        curr = explore.pop()
        if curr in explored:
            continue
        explored.add(curr)
        names.add(curr.name.lower())
        for toexlore in curr.inheritance:
            explore.append(toexlore)
            names.add(toexlore.name.lower())
    return names

def get_emitted_events(f: FunctionContract) -> List[str]:
    ev_calls = [op for op in f.all_slithir_operations() if isinstance(op, EventCall)]
    return [ev.name for ev in ev_calls]


def get_public_state_var_sigs(c: Contract) -> Set[str]:
    """get a list of public state variables

    Args:
        c (Contract): _description_

    Returns:
        Set[str]: List of state variable as signature
    """
    signatures = set()
    explore = [c]
    explored = set()
    while len(explore) != 0:
        curr = explore.pop()
        if curr in explored:
            continue
        explored.add(curr)

        for toexlore in curr.inheritance:
            explore.append(toexlore)

        for cv in curr.state_variables:
            # print(cv, cv.visibility, cv.full_name, curr.name)
            if cv.visibility == "public":
                signatures.add(cv.signature_str)
    return signatures


def get_erc_number(c: Contract) -> str:
    names = get_contract_names(c)
    for name in names:
        idx = name.find("erc")
        if idx != -1:
            return name[idx + 3 :]
    return None


def get_erc_numbers(c: Contract) -> List[str]:
    ercs = set()
    names = get_contract_names(c)
    for name in names:
        idx = name.find("erc")
        if idx != -1:
            ercs.add(name[idx + 3 :])
    return list(ercs)

def get_all_pragma_solidity_versions(text: str) -> List[str]:
    prefix = "pragma solidity "
    return [
        line[len(prefix) : -1]
        for line in text.splitlines()
        if line.startswith("pragma solidity")
    ]

def get_minmatch_solidity_version(text: str) -> str:
    """A solidity file might contains multiple
    "pragma solidity x.x.x". Find the most lowest
    match one and return.

    Args:
        text (str): Solidity source file

    Returns:
        str: lowest solidity version that matched the pragma
        version constraint.
    """
    versions = get_all_pragma_solidity_versions(text)
    # if len(versions) == 1 and versions[0] == "^0.4.13":
    #     return "0.4.17"
    max = (0, 0, 0)
    for ver_str in versions:
        ver_str = ver_str.replace(" ", "")
        if ver_str[0] == "^" or ver_str[0] == "=":
            ver_str = ver_str[1:]
        elif ver_str[1] == "=":
            # match either >= or <=
            ver_str = ver_str[2:]

        [maj, minor, patch] = ver_str.split(".")[:3]
        match = re.search(r"\D", patch)  # Find the first non-number character
        if match:
            patch = patch[: match.start()]
        maj = int(maj)
        if minor == "*":
            minor = 0
        else:
            minor = int(minor)
        if patch == "*":
            patch = 0
        else:
            patch = int(patch)
        ver_tuple = (maj, minor, patch)
        if maj > max[0]:
            max = ver_tuple
        elif maj == max[0]:
            if minor > max[1]:
                max = ver_tuple
            elif minor == max[1]:
                if patch > max[2]:
                    max = ver_tuple

    res = f"{max[0]}.{max[1]}.{max[2]}"
    if max[1] == 4 and max[2] < 17:
        return "0.4.17"
    return res


def ensure_solc_version(text: str, use_solc_ver = None) -> str:
    """Make sure solc version is matched with
    the given solidity source file by using
    solc-select

    Args:
        text (str): Solidity source code
    """
    if use_solc_ver is None:
        ver = get_minmatch_solidity_version(text)
    else:
        ver = use_solc_ver
    # Note: here the best way is to install & use
    # after comparing the solc current version and
    # min-require version from source code.
    # Too lazy to implement it.
    if ver == "0.0.0":
        ver = "0.8.20"
    ret = subprocess.run(
        ["solc-select", "install", ver],
        stdout=subprocess.DEVNULL,
    )
    ret.check_returncode()
    ret = subprocess.run(
        ["solc-select", "use", ver],
        stdout=subprocess.DEVNULL,
    )
    ret.check_returncode()
    return ver

def compile(
    sol_file_or_dir: str,
    auto_solc=True,
    solc_version=None
) -> Tuple[str, SlitherCompilationUnit]:
    
    if not solc_version and auto_solc:
        with open(sol_file_or_dir, 'r') as f: 
            solc_version = ensure_solc_version(f.read())
    
    if solc_version is None:
        solc_version = "0.8.20"
    logger.debug(f"file='{sol_file_or_dir}' solc='{solc_version}'")
    
    slither = Slither(sol_file_or_dir)
    cu = slither.compilation_units[0]
    return solc_version, cu

def get_contracts_and_ercs(cu: SlitherCompilationUnit, \
    cname=None, cname2ercs: Dict = None) -> Dict[Contract, List[str]]:
    contracts_ercs: Dict[Contract, List[str]] = {}
    if not cname:
        inherited = {}
        for c in cu.contracts_derived:
            for inh in c.inheritance:
                inherited[inh] = True
        for c in cu.contracts_derived:
            if c in inherited:
                logger.debug(f"skip {c.name}, this is not final one")
                continue
            if c.is_library:
                continue
            if c.is_interface:
                # print(f"skip interface {c.name}")
                continue
            
            if cname2ercs and c.name in cname2ercs:
                ercs = cname2ercs[c.name]
            else:
                ercs = get_erc_numbers(c)
            if ercs:
                contracts_ercs[c] = ercs
    else:
        selected_contracts = cu.get_contract_from_name(cname)
        if len(selected_contracts) == 0:
            raise RuntimeError(
                f"no contract '{cname}' found"
            )

        if len(selected_contracts) > 1:
            raise RuntimeError(
                f"multiple contracts '{cname}' found"
            )

        if cname in cname2ercs:
            ercs = cname2ercs[cname]
        else:
            ercs = get_erc_numbers(selected_contracts[0])
        if ercs:
            contracts_ercs[c] = ercs
        else:
            raise RuntimeError(
                f"contracts '{cname}' does not implement any ERC"
            )
    return contracts_ercs


def get_ifelse_blocks(f: FunctionContract, file_lines:List[str]):
    infos = []
    
    fstart = min(f.entry_point.source_mapping)
    fend = max(f.source_mapping.lines) - 1
    i = fstart
    indent_level = 0
    while i <= fend:
        line_str = file_lines[i-1]
        line_str = line_str.strip()
        if line_str.startswith("if"):
            ifs = []
            while i <= fend:
                line_str = file_lines[i-1]
                line_str = line_str.strip()
                ifs.append(i)
                if line_str.endswith("{"):
                    indent_level += 1
                    break
                i += 1
            infos.append({"type":"if", "cond": ifs, "indent": indent_level})
        else:
            if line_str.startswith("}"):
                infos[-1]["end"] = i
                indent_level -= 1
            if line_str.strip().find(" else "):
                infos.append({"type":"else", "cond": [i], "indent": indent_level})

        i += 1
    return infos

        
                

def emit_if_vars_changed(f: FunctionContract, ev:str, vars:List[str], calls:List[str], should_emit = True):
    if f.is_constructor:
        vars_written = [item for fc in f.contract.constructors for item in fc.all_state_variables_written() ]
    else:
        vars_written = f.all_state_variables_written()
    
    matched_vars = 0
    for var in vars:
        for var_written in vars_written:
            if var_written.full_name.lower().find(var.lower()) != -1:
                matched_vars += 1
                break

    if matched_vars == 0:
        # no matched vars means emit condition does not match
        return True
    
   
    if calls:
        called_calls = set([call.name  for call in f.all_internal_calls()])
        # self count as well
        called_calls.add(f.name)
        matched_calls = set(calls) & called_calls
        
        if len(matched_calls) != len(calls):
            return True

    emitted_events = get_emitted_events(f)
    return any([ee==ev for ee in emitted_events])


def get_the_function(cu: SlitherCompilationUnit, contract_name:str, fi: SolidityFunctionFormat=None, fname:str = None, fnumofargs:int=None) -> FunctionContract:
    contracts = [c for c in cu.contracts if c.name == contract_name]
    if not contracts:
        logger.info(f"does not find contract '{contract_name}'")
        return None
    c = contracts[0]
    function_name = fi['name'] if fi else fname
    fnumofargs = len(fi['arg_types']) if fi else  fnumofargs
    if function_name == "constructor":
        f = c.constructor
        if not f:
            logger.info(f"does not find constructor in contract '{contract_name}'")
            return None
        return f
    functions = [f for f in c.functions if f.name == function_name \
                 and (not fnumofargs or len(f.parameters) == fnumofargs) \
                    and not f.contract_declarer.is_interface ]
    if not functions:
        logger.info(f"does not find function '{function_name}' in contract '{contract_name}'")
        return None
    if len(functions) > 1:
        has_been_overrides = set()
        
        for i, f in enumerate(functions):
            for j in range(i+1, len(functions)):
                jf = functions[j]
                if jf.contract_declarer in f.contract_declarer.inheritance:
                    has_been_overrides.add(jf)
                else:
                    has_been_overrides.add(f)
        functions = [f for f in functions if f not in has_been_overrides]
    if len(functions) != 1:
        logger.error(f"In contract '{contract_name}', fi '{fi}', found more {len(functions)} match: {functions}")
        for f in functions:
            logger.debug(f"{f.name}, {f.contract}, {f.contract_declarer}")
        return None
    f = functions[0]
    return f



def get_events_summary(c: Contract, anchor_functions=[]) -> Dict[str, str]:
    anchor2func = {}
    total_summary = {}
    for f in c.functions:
        if f.pure or f.is_empty or f.is_empty is None:
            continue
        
        if f.name in anchor_functions:
            sv = get_anchored_state_variable(f)
            anchor2func[sv] = f.name
    
    
    for f in c.functions:
        if f.pure or f.view or f.is_empty or f.is_empty is None:
            continue    
        summary = get_events_summary_for_function(f)
        for ename, sv in summary.items():
            total_summary[ename] = {
                "state_var": sv.name,
                "state_var_anchor": anchor2func.get(sv, None)
            }

    return total_summary

def get_anchored_state_variable(f: FunctionContract) -> StateVariable:
    for var in f.return_values:
        if isinstance(var, StateVariable):
            return var
        elif isinstance(var, ReferenceVariable):
            return var.points_to_origin
        elif isinstance(var, LocalVariable):
            # if return is a local variable, usually is return of another function
            if isinstance(var.expression, CallExpression):
                returned_by_arr = [c for c in f.internal_calls if c.name == str(var.expression.called)]
                if not returned_by_arr:
                    print("cannot find callee to get anchored state variable")
                    return None
                returned_by = returned_by_arr[0]
                return get_anchored_state_variable(returned_by)
    print(f"does not find anchored state variable at {f.name}")

def get_events_summary_for_function(f: FunctionContract):
    ev_calls = [op for op in f.all_slithir_operations() if isinstance(op, EventCall)]

    # reference to the state variale
    ref2state = {}

    # variables that assign to state variable refernece
    vars_written_to_state = {}

    event_related_state_vars = {}
    for op in f.all_slithir_operations():
        if isinstance(op, Index):
            if isinstance(op.variable_left, StateVariable):
                ref2state[op.lvalue] = op.variable_left
            elif op.variable_left in ref2state:
                ref2state[op.lvalue] = ref2state[op.variable_left]
                # print("found state ref", op.lvalue)
    for op in f.all_slithir_operations():
        if isinstance(op, Assignment):
            # print("Found assign", op.lvalue, op.rvalue)
            if op.lvalue in ref2state:
                vars_written_to_state[op.rvalue] = ref2state[op.lvalue]

    # print(vars_written_to_state)
    for ev_call in ev_calls:
        for arg in ev_call.arguments:
            if arg in vars_written_to_state:
                event_related_state_vars[ev_call.name] = vars_written_to_state[arg]
                print(f"found related state variable {vars_written_to_state[arg]}")

    return event_related_state_vars


def find_throw_nodes(initf: FunctionContract, params: List[int] = None, msg_sender=False) -> Set[Node]:
    """get matched throw related nodes, including require, protected arithmatic operation, 
    assert, etc.

    Args:
        initf (FunctionContract): _description_
        params (List[int], optional): _description_. Defaults to None.
        msg_sender (bool, optional): _description_. Defaults to False.

    Returns:
        Set[Node]: Matched throw related nodes
    """
    related_nodes = set()

    fn2cared = {}
    fn2cared[initf] = set()
    fn2params = {}
    if params is None:
        params = []
    fn2params[initf] = params
    to_explore: List[FunctionContract] = [initf]
    explored: Set[FunctionContract] = set()
    dirty_fns:Set[FunctionContract] = set()
    
    # minimal req: function's signature is needed
    dirty_fns.add(initf)
    
    cond_callsite_lines: Dict[Operation, FunctionContract] = {}
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
            has_cared_vars = False
            callees:List[str] = []
            
            if node.calls_as_expression:
                for ir in node.irs:
                    if isinstance(ir, HighLevelCall):
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

            if has_cared_vars and node.contains_require_or_assert():
                related_nodes.add(node)
    return related_nodes


def get_function_body_range(lines:List[str], fstart:int, fend:int):
    body_start = None
    i = fstart
    while i < fend:
        if lines[i-1].strip(" \n").endswith("{") and body_start is None:
            body_start = i+1
            break
        i += 1
    
    return body_start, fend-1
