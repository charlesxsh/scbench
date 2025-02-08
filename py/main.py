import logging
from log import setup_logging
setup_logging()
logger = logging.getLogger(__name__)
import click
import json
import os
from glob import glob
from errinj.pm import inject_err_to_contract
import config
from llm.utils import trim_json_markers
from llm.adapters import OpenAILLMAdapter
from typing import List
from sol.utils import get_the_function, get_public_state_var_sigs, compile
from utils import find_all_callees, slithir_funcs_to_text


@click.group()
def main():
    pass

@main.command()
@click.argument("ERC_FILE", type=click.Path(exists=True, dir_okay=False))
@click.argument("OUT", type=click.Path(exists=False, file_okay=False))
def inject(erc_file, out):
    if not os.path.exists(out):
        os.makedirs(out)
    inject_err_to_contract(erc_file, out)

@main.command()
@click.argument("OUT", type=click.Path(exists=False, file_okay=False))
def batch_inject(out):
    if not os.path.exists(out):
        os.makedirs(out)
    import tasks
    files = glob("dataset/err-inj/origin/*.sol")
    [tasks.process_file.s(file, out).delay() for file in files]

@main.command()
def info():
    """print dataset info
    """
    err_dist = {
        "20": { "call": 0, "emit": 0, "throw": 0, "interface": 0, "assign": 0, "return": 0},
        "721": { "call": 0, "emit": 0, "throw": 0, "interface": 0, "assign": 0, "return": 0},
        "1155": { "call": 0, "emit": 0, "throw": 0, "interface": 0, "assign": 0, "return": 0}
    }
    contracts_dist = {
        "20": 0,
        "721": 0,
        "1155": 0
    }
    err_severity = {
        "high": 0,
        "medium": 0,    
        "low": 0
    }
    err_cnt = 0
    contracts_cnt = 0
    throw_high_cnt = 0
    loc = []
    files = glob("dataset/err-inj/injected/*.json")
    for file in files:
        with open(file, 'r') as f:
            meta = json.load(f)
        
        if file.endswith("-res.json"):
            continue
        if meta['compile_error']:
            continue
        erc = meta['erc']
        
        # calculate the lines of code
        try:
            with open(meta['inj_file'], "r") as f:
                loc.append(len(f.readlines()))
        except Exception as ex:
            with open(meta['orig_file'], "r") as f:
                loc.append(len(f.readlines()))
        contracts_cnt += 1
        for err_inj in meta['inj_errors']:
            inj_ty = err_inj['config'][0]
            err_dist[erc][inj_ty] += 1
            severity = err_inj['config'][1]['severity']
            err_cnt += 1
            if severity == "high" and inj_ty == "throw":
                throw_high_cnt += 1
            err_severity[severity] += 1
        contracts_dist[erc] += 1

    print(err_dist)
    print("throw high cnt",throw_high_cnt)
    # Calculate totals for each row (ERC20, ERC721, ERC1155)
    row_totals = {erc: sum(actions.values()) for erc, actions in err_dist.items()}
    # Calculate totals for each column (call, emit, throw, interface, assign, return)
    column_totals = {}
    for actions in err_dist.values():
        for action, count in actions.items():
            column_totals[action] = column_totals.get(action, 0) + count

    print(row_totals)
    print(column_totals)
    print(contracts_dist)
    print("loc", sum(loc) / contracts_cnt)
    import math
    print("loc std deviation", math.sqrt(sum([(x - sum(loc) / contracts_cnt) ** 2 for x in loc]) / contracts_cnt))
    print("total errors", err_cnt)
    for k, v in err_severity.items():
        print(k, v / err_cnt)
def simple_audit(errs_json, llm_adapter):
    with open(errs_json, "r") as f:
        err_configs = json.load(f)
    for err_config in err_configs:
        contract_file = "./"+err_config['filepath']
        contract_name = err_config['contract']
        
        _, cu = compile(contract_file)
        with open(contract_file, "r") as f:
            file_lines = f.read().splitlines(True)

        if err_config["type"] == "interface":
            contracts = [c for c in cu.contracts if c.name == contract_name]
            if not contracts:
                logger.info(f"does not find contract '{contract_name}'")
                return None
            c = contracts[0]

            # use all signatures, rule, contract name, function name to construct audit prompt.
            fn_interfaces: List[str] = c.functions_signatures
            event_interfaces: List[str] = [f.full_name for f in c.events]
            statevar_interfaces: List[str] = list(get_public_state_var_sigs(c))
            interfaces_str = "\n".join(fn_interfaces + event_interfaces + statevar_interfaces)
            prompt = "The following code is the interface of contract " + contract_name + ". ERC rules require contracts to have "+err_config['rule']+". Does this interface contain this? Answer YES or NO. \n code:```\n"+interfaces_str+"\n```"

            response = llm_adapter.ask([{"content": prompt, "role":"user"}])
            if response:
                err_config["llm_can_detect"] = "NO" in response[0]
        else:
            function_name = err_config['function']
            fn = get_the_function(cu, contract_name, fname=function_name)
            if not fn:
                continue

            # use func_text, rule, contract name, function name to construct audit prompt.
            to_explore = set()
            to_explore.add(fn)
            explored = find_all_callees(to_explore)
            func_text = slithir_funcs_to_text(explored, file_lines, True, False, True, True)
            prompt = "The following code is the implementation of function "+function_name+" in contract " + contract_name + ". ERC rules require \""+err_config['rule']+"\". Does this interface violate this rule? Answer YES or NO. \n code:```\n"+func_text+"\n```"
            
            response = llm_adapter.ask([{"content": prompt, "role":"user"}])
            if response:
                err_config["llm_can_detect"] = "YES" in response[0]

    with open(errs_json, "w") as f:
        json.dump(err_configs, f, indent=4)

@main.command()
@click.argument("folder", type=click.Path(exists=True))
def simple_audit_batch(folder):
    llm_adapter = OpenAILLMAdapter(config.OPENAI_KEY, "gpt-4-turbo")
    for filename in os.listdir(folder):
        if ".json" not in filename:
            continue
        simple_audit("./"+folder+filename, llm_adapter)

@main.command()
@click.argument("folder", type=click.Path(exists=True))
@click.option("--type") # example: ERC20
@click.option("--out")
def full_audit_batch(folder, type, out):
    llm_adapter = OpenAILLMAdapter(config.OPENAI_KEY, "gpt-4-turbo")
    for filename in os.listdir(folder):
        if ".sol" not in filename:
            continue
        contract_file = "./"+folder+filename
        full_audit(llm_adapter, contract_file, type, out)

def full_audit(llm_adapter,filepath, erctype, out):
    c_file = open(filepath, "r")
    code = c_file.read()
    c_file.close()
    erc_file = open("./erc/"+erctype)
    erc_rules = erc_file.read()
    erc_file.close()    
    prompt = "The following code is an implementation of "+erctype+". The "+erctype+" rules is attached below the code. Does this implementation violate "+erctype+" rules? Return a JSON array containing JSON objects with 'rule' and 'function' as keys, indicating the specific rule content that is violated and the function where the violation resides.\ncode:```\n"+code+"\n```\n"+erctype+":\n"+erc_rules
    response = llm_adapter.ask([{"content": prompt, "role":"user"}])[0]
    detect_res = json.loads(trim_json_markers(response))
    res_file = open(out+filepath.split("/")[-1].split(".")[0]+".json","w")
    json.dump(detect_res, res_file, indent=4)
    res_file.close()

@main.command()
@click.argument("folder", type=click.Path(exists=True))
@click.option("--err-dir")
@click.option("--out")
def rule_audit_batch(folder, err_dir, out):
    llm_adapter = OpenAILLMAdapter(config.OPENAI_KEY, "gpt-4-turbo")
    for filename in os.listdir(folder):
        if ".sol" not in filename:
            continue

        errs_json = "./"+err_dir+filename.split(".")[0]+".json"
        if not os.path.exists(errs_json):
            continue
        contract_file = "./"+folder+filename
        c_file = open(contract_file, "r")
        code = c_file.read()
        c_file.close()

        with open(errs_json, "r") as f:
            err_configs = json.load(f)
        for err_config in err_configs:
            func_name = err_config.get("function")
            err_config["llm_can_detect"] = audit(code, err_config['rule'], err_config['contract'], func_name, llm_adapter)

        with open(out+filename.split(".")[0]+".json", "w") as f:
            json.dump(err_configs, f, indent=4)

def audit(code: str, rule:str, contract:str, function:str, llm_adapter: OpenAILLMAdapter) -> bool:
    prompt = f"""Whether the following smart contract {contract} violate ERC rule \"{rule}\" {("for function "+function) if function else ""}? Answer YES or NO.
            Code:\"\"\"
            {code}
            \"\"\"
            """
    res = llm_adapter.ask([{"content": prompt, "role":"user"}], temperature=0, n=1)[0]
    return res.find("YES") != -1

def open_file(fp:str):
    with open(fp, "r") as f:
        return f.read()



@main.command()
def batch_run_llm():
    """Run LLM (method-1,-2,-3) for the error injected contracts,
    and record the response to the json filename with suffix "-res".
    Ex. abc.json, response file is abc-res.json
    """
    files = glob("dataset/err-inj/injected/*.json")
    llm_adapter = OpenAILLMAdapter(config.OPENAI_KEY, "gpt-4-turbo")
    base_dir = "dataset/err-inj/injected"
    erc_file_cache = {
        "20": open_file("erc/ERC20"),
        "721": open_file("erc/ERC721"),
        "1155": open_file("erc/ERC1155")
    }

    erc_cnt = {
        "20": 0,
        "721": 0,
        "1155": 0
    }
    
    for file in files:
        filename = os.path.basename(file).split(".")[0]
        if filename.endswith("-res"):
            continue    
        print(f"-> {file}")
        res_file = os.path.join(base_dir, filename+"-res.json") 
        
        with open(file, 'r') as f:
            meta = json.load(f)
        
        if meta['compile_error']:
            continue
        erc = meta['erc']
        inj_file = meta['inj_file']
        contract = meta['contract']

        if erc == "20" and erc_cnt[erc] >= 1000:
            continue
        erc_cnt[erc] += 1
        
        
        res = {
            "method1": None,
            "method2": None,
            "method3": None
        }
        
        if os.path.exists(res_file):
            print(f"-> {res_file}")
            with open(res_file, "r") as f:
                res = json.load(f)
        with open(inj_file, "r") as f:
            inj_file_content = f.read()
        
        changed = False
        # Method-1 Full Contract + Full ERC (both correct, rule is correct, neither is correct)
        if "method1" not in res or res["method1"] is None:
            changed = True
            res["method1"] = {}
            prompt = "The following code is an implementation of ERC"+erc+". The ERC"+erc+" rules is attached below the code. Does this implementation violate ERC"+erc+" rules? Return a JSON array containing JSON objects with 'rule' and 'function' as keys, indicating the specific rule content that is violated and the function where the violation resides.\ncode:```\n"+inj_file_content+"\n```\nERC"+erc+":```\n"+erc_file_cache[erc] + "\n```"
            try:
                response = llm_adapter.ask([{"content": prompt, "role":"user"}])[0]
                detect_res = json.loads(trim_json_markers(response))
                res["method1"]["llm_res"] = detect_res
            except Exception as ex:
                res["method1"]["error"] = str(ex)
    
        # Method-2 Full Contract + Single Violated Rule (TP, FN)
        if "method2" not in res or res['method2'] is None:
            res['method2'] = {'llm_res': [], 'can_detect':[], "error":[]}
            changed = True
            code = inj_file_content
            for err_inj in meta['inj_errors']:
                inj_ty = err_inj['config'][0]
                rule = err_inj['config'][1]['rule']
                function =err_inj['config'][1].get('function', None)
                prompt = f"""Whether the following smart contract {contract} violate ERC rule {rule} {("for function "+function) if function else ""}? Answer YES or NO.
Code:\"\"\"
{code}
\"\"\"
            """
                try:
                    llmres = llm_adapter.ask([{"content": prompt, "role":"user"}], temperature=0, n=1)[0]
                    can_detect = llmres.find("YES") != -1
                    res['method2']['llm_res'].append(llmres)
                    res['method2']['can_detect'].append(can_detect)
                    res['method2']['error'].append(None)
                except Exception as ex:
                    res['method2']['llm_res'].append(None)
                    res['method2']['can_detect'].append(None)
                    res['method2']['error'].append(str(ex))
                
        
        # Method-3 Sliced Code + Single Violated Rule   (TP, FN)
        if "method3" not in res or res['method3'] is None:
            changed = True
            res['method3'] = {'llm_res': [], 'can_detect':[], "error":[]}
            try:
                _, cu = compile(inj_file)
            except Exception as ex:
                print(ex)
                continue
            file_lines = inj_file_content.splitlines(True)
            contract_name = contract
            for err_inj in meta['inj_errors']:
                inj_ty = err_inj['config'][0]
                rule = err_inj['config'][1]['rule']
                function = err_inj['config'][1].get('function', None)
                try:
                    if inj_ty == "interface":
                        contracts = [c for c in cu.contracts if c.name == contract_name]
                        if not contracts:
                            res['method3']['llm_res'].append(None)
                            res['method3']['can_detect'].append(False)
                            res['method3']['error'].append("cannot find the contract")
                            continue
                        c = contracts[0]

                        # use all signatures, rule, contract name, function name to construct audit prompt.
                        fn_interfaces: List[str] = c.functions_signatures
                        event_interfaces: List[str] = [f.full_name for f in c.events]
                        statevar_interfaces: List[str] = list(get_public_state_var_sigs(c))
                        interfaces_str = "\n".join(fn_interfaces + event_interfaces + statevar_interfaces)
                        prompt = "The following code is the interface of contract " + contract_name + ". ERC rules require contracts to have "+rule+". Does this interface contain this? Answer YES or NO. \n code:```\n"+interfaces_str+"\n```"

                        llmres = llm_adapter.ask([{"content": prompt, "role":"user"}])[0]
                        can_detect = llmres.find("NO") != -1
                        res['method3']['llm_res'].append(llmres)
                        res['method3']['can_detect'].append(can_detect)
                        res['method3']['error'].append(None)
                    else:
                        if function is None:
                            function = err_inj['inj_fn']
                       
                        fn = get_the_function(cu, contract_name, fname=function)
                        if not fn:
                            res['method3']['llm_res'].append(None)
                            res['method3']['can_detect'].append(False)
                            res['method3']['error'].append("cannot find the function")
                            continue

                        # use func_text, rule, contract name, function name to construct audit prompt.
                        to_explore = set()
                        to_explore.add(fn)
                        explored = find_all_callees(to_explore)
                        func_text = slithir_funcs_to_text(explored, file_lines, True, False, True, True)
                        prompt = "The following code is the implementation of function "+function+" in contract " + contract_name + ". ERC rules require \""+rule+"\". Does this function violate this rule? Answer YES or NO. \n code:```\n"+func_text+"\n```"
                        
                        llmres = llm_adapter.ask([{"content": prompt, "role":"user"}])[0]
                        can_detect = llmres.find("YES") != -1
                        res['method3']['llm_res'].append(llmres)
                        res['method3']['can_detect'].append(can_detect)
                        res['method3']['error'].append(None)
                except Exception as ex:
                    res['method3']['llm_res'].append(None)
                    res['method3']['can_detect'].append(None)
                    res['method3']['error'].append(str(ex))
                    
            
        
        
        
        if changed:
            with open(res_file, "w") as f:
                json.dump(res, f, indent=4)
            print(f"[+] {res_file}")


def check_word_overlap(text, s):
    # Split the input text into words and create a set of unique words
    text_words = set(text.split())
    
    # Calculate the number of unique words in the input text
    text_unique_count = len(text_words)

    # Split the string into words and create a set of unique words
    s_words = set(s.split())
    
    # Calculate the intersection of unique words between the text and the current string
    common_words = text_words & s_words
    
    # Calculate the percentage of overlap
    overlap_percentage = len(common_words) / text_unique_count
    
    # Check if the overlap is at least 80%
    if overlap_percentage >= 0.8:
        return True

    # If no string in the list has an 80% overlap, return False
    return False

def match_rule_in_inj_error(rule:str, inj_error, fn=None) -> str:
    inj_rule = inj_error['config'][1]['rule']
    inj_func = inj_error['config'][1].get('function', None)
    if check_word_overlap(rule, inj_rule):
        if inj_func is None:
            return "bc"
        elif fn and fn.find(inj_func) != -1:
            return "bc"
        else:
            return "rc"

    return "nc"



def get_rule_type(rule):
    if rule.find("return") != -1:
        return "return"
    elif rule.find("emit") != -1 or rule.find("trigger") != -1:
        return "emit"
    elif rule.find("overwrite") != -1:
        return "assign"
    elif rule.find("throw") != -1:
        return "throw"
    elif rule.find("call") != -1:
        return "call"
    else:
        return "interface"
def check_impact(rule, fn):
    type = get_rule_type(rule)
    if type == "throw" and fn.find("transfer") != 1:
        return "high"
    elif (type == "return" and (fn.find("transferOf") != -1 or fn.find("getApproved") != -1 or fn.find("allowance") != -1  ) ) \
        or type == "call" or type == "assign":
        return "high"
    elif type == "emit":
        return "low"
    else:
        return "medium"
    
@main.command()
def show():
    files = glob("dataset/err-inj/injected/*.json")
    base_dir = "dataset/err-inj/injected"
    
    # Method-1 Full Contract + Full ERC (both correct, rule is correct, neither is correct)
    # Method-2 Full Contract + Single Violated Rule (TP, FN)
    # Method-3 Sliced Code + Single Violated Rule   (TP, FN)
    stats = {
        "method1": {
            "20": {
                "high": {"bc":0, "rc":0, "nc": 0},
                "medium": {"bc":0, "rc":0, "nc": 0},
                "low": {"bc":0, "rc":0, "nc": 0}
            },
            "721": {
                "high": {"bc":0, "rc":0, "nc": 0},
                "medium": {"bc":0, "rc":0, "nc": 0},
                "low": {"bc":0, "rc":0, "nc": 0}
            },
            "1155": {
                "high": {"bc":0, "rc":0, "nc": 0},
                "medium": {"bc":0, "rc":0, "nc": 0},
                "low": {"bc":0, "rc":0, "nc": 0}
            }
        },
        "method2": {
            "20": {
                 "high": {"tp":0, "fn": 0},
                "medium": {"tp":0, "fn": 0},
                "low": {"tp":0, "fn": 0},
            },
            "721": {
                 "high": {"tp":0, "fn": 0},
                "medium": {"tp":0, "fn": 0},
                "low": {"tp":0, "fn": 0},
            },
            "1155": {
                 "high": {"tp":0, "fn": 0},
                "medium": {"tp":0, "fn": 0},
                "low": {"tp":0, "fn": 0},
            }
           
        },
        "method3": {
            "20": {
                 "high": {"tp":0, "fn": 0},
                "medium": {"tp":0, "fn": 0},
                "low": {"tp":0, "fn": 0},
            },
            "721": {
                 "high": {"tp":0, "fn": 0},
                "medium": {"tp":0, "fn": 0},
                "low": {"tp":0, "fn": 0},
            },
            "1155": {
                 "high": {"tp":0, "fn": 0},
                "medium": {"tp":0, "fn": 0},
                "low": {"tp":0, "fn": 0},
            }
        }
    }
    
    missing_res = []
    has_cond = 0
    m2_err_dist = {
        "20": { "call": {"total":0, "tp": 0}, "emit":{"total":0, "tp": 0}, "throw": {"total":0, "tp": 0}, "interface": {"total":0, "tp": 0}, "assign": {"total":0, "tp": 0}, "return": {"total":0, "tp": 0}},
        "721": { "call": {"total":0, "tp": 0}, "emit":{"total":0, "tp": 0}, "throw": {"total":0, "tp": 0}, "interface": {"total":0, "tp": 0}, "assign": {"total":0, "tp": 0}, "return": {"total":0, "tp": 0}},
        "1155": { "call": {"total":0, "tp": 0}, "emit":{"total":0, "tp": 0}, "throw": {"total":0, "tp": 0}, "interface": {"total":0, "tp": 0}, "assign": {"total":0, "tp": 0}, "return": {"total":0, "tp": 0}},
    }
    m3_err_dist = {
        "20": { "call": {"total":0, "tp": 0}, "emit":{"total":0, "tp": 0}, "throw": {"total":0, "tp": 0}, "interface": {"total":0, "tp": 0}, "assign": {"total":0, "tp": 0}, "return": {"total":0, "tp": 0}},
        "721": { "call": {"total":0, "tp": 0}, "emit":{"total":0, "tp": 0}, "throw": {"total":0, "tp": 0}, "interface": {"total":0, "tp": 0}, "assign": {"total":0, "tp": 0}, "return": {"total":0, "tp": 0}},
        "1155": { "call": {"total":0, "tp": 0}, "emit":{"total":0, "tp": 0}, "throw": {"total":0, "tp": 0}, "interface": {"total":0, "tp": 0}, "assign": {"total":0, "tp": 0}, "return": {"total":0, "tp": 0}},
    }
    m1res = []
    existing_res = []
    
    for file in files:
        filename = os.path.basename(file).split(".")[0]
        if filename.endswith("-res"):
            continue    
        
        res_file = os.path.join(base_dir, filename+"-res.json") 
        
        with open(file, 'r') as f:
            meta = json.load(f)
        
        if meta['compile_error']:
            continue
        inj_errors = meta['inj_errors']
        
        if os.path.exists(res_file):
            # print(f"-> {file}")
            # print(f"-> {res_file}")
            with open(res_file, "r") as f:
                res = json.load(f)
            existing_res.append(res_file)
        else:
            missing_res.append(file)
            
            continue
        
        
        
        


        # check method1
        for item in res["method1"].get("llm_res", []):
            rule = item['rule']
            func = item['function']
            best_res = "nc"
            
            for i, inj_error in enumerate(inj_errors):
                mres = match_rule_in_inj_error(rule, inj_error, func)
                if best_res is None:
                    best_res = mres
                elif mres == "bc":
                    best_res = mres
                    break
                elif mres == "rc":
                    best_res = mres
            
            inj_severity = check_impact(rule, func)
            stats['method1'][meta['erc']][inj_severity][best_res] += 1
        
        
            
        
        # check method2
        detect_res = res["method2"].get("can_detect", [])
        for i, inj_error in enumerate(inj_errors):
            inj_severity = inj_error['config'][1]['severity']
            key = "tp" if detect_res[i] else "fn"
            stats['method2'][meta['erc']][inj_severity][key] += 1
            
            m2_err_dist[meta['erc']][inj_error['config'][0]]["total"] += 1
            if key == "tp":
                m2_err_dist[meta['erc']][inj_error['config'][0]]["tp"] += 1

        # check method3
        detect_res = res["method3"].get("can_detect", [])
        for i, inj_error in enumerate(inj_errors):
            inj_severity = inj_error['config'][1]['severity']
            key = "tp" if detect_res[i] else "fn"
            stats['method3'][meta['erc']][inj_severity][key] += 1
            
            m3_err_dist[meta['erc']][inj_error['config'][0]]["total"] += 1
            if key == "tp":
                m3_err_dist[meta['erc']][inj_error['config'][0]]["tp"] += 1
            
    print(stats)
    print(len(missing_res))
    # print("method2 sum", stats["method2"]["high"]["tp"]+stats["method2"]["high"]["fn"] \
    #             +stats["method2"]["medium"]["tp"]+stats["method2"]["medium"]["fn"] + \
    #             stats["method2"]["low"]["tp"]+stats["method2"]["low"]["fn"] 
    #         )
    
    # print("method3 sum", stats["method3"]["high"]["tp"]+stats["method3"]["high"]["fn"] \
    #             +stats["method3"]["medium"]["tp"]+stats["method3"]["medium"]["fn"] + \
    #             stats["method3"]["low"]["tp"]+stats["method3"]["low"]["fn"] 
    #         )
    