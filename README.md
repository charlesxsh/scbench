# SCBench
A Large-Scale Dataset for Smart Contract Auditing

## Project Structure
```
dataset/    # contains the manual-inspected and error-injected smart contracts
    - audited/    # manual-inspected
    - err-inj/    # error-injected
        - injected   # injected smart contracts
            - <filename>.sol  # error-injected smart contract
            - <filename>.json # contains the information about injected errors
            - <filename>-res.json # contains the LLM responses of full-rule prompting and oracle prompting
        - origin     # original smart contracts
            - <filename>.sol  # original smart contract
```

## File Formats
### \<filename>-res.json
```
{
    "method1": {
        "llm_res": [
            # here is the LLM responses of full-rule prompting
        ]
    },
    "method2": {
        "llm_res": [
            # here is the LLM responses of oracle prompting
        ],
        "can_detect": [
            # here is whether the corresponding responses indicates the bug has been identidied by the LLM
        ],
        "error": [
            # here is whether there is any error/exception happened during this process
        ] 
    }
}
```

### \<filename>.json
```
{
    "erc":  // Specifies the Ethereum token standard used in the contract (e.g., ERC-1155)
    "contract":  // Represents the name or identifier of the contract being analyzed
    "inj_file": // Path to the injected version of the contract source file, which contains modifications introducing errors for testing
    "orig_file": // "Path to the original, unmodified contract source file
    "inj_errors": [
            {
                // Defines the error rule and metadata about the injection
                "type": // Type of injection applied (e.g., 'throw', 'interface')."
                "rule": // Description of the rule applied to the function."
                "function": // Name of the function affected by the error injection."
                "numofargs":  // Number of arguments in the function signature."
                "fn_params": // Specifies which function parameters are involved in the rule."
                "severity": // Indicates the severity of the issue (e.g., 'high', 'medium')."
                "lines":  // Specifies the lines in the source code where the error appears.",
                    {
                        "orig_range": // "Line numbers in the original contract where modifications were made."
                        "to_replace": // "Placeholder for potential code replacements."
                        
                    }
                }
            }
        ]
    "compile_error": // "Stores any compilation errors caused by the injected modifications. If 'null', no compilation errors were found."
}

```


## Dev
```bash
$ python3 -m venv .venv
$ source .venv/bin/activate
$ pytest
```


## Err-Inj Database Info

|      | call | emit | throw | interface | assign | return | total | # of contracts |
|------|------|------|-------|-----------|--------|--------|-------|---|
| ERC-20  | 0    | 3612    | 566     | 4605         | 736      | 5930      | 15449     |  5211 |
| ERC-721 | 15    | 33    | 158     | 72         | 0      | 48      | 326     | 110 |
| ERC-1155| 4    | 0    | 18     | 30        | 0      | 9     | 61     | 26 |
| Total   | 19    | 3645    | 742     | 4707    | 736      | 5987      | 15836     | 5347 |


### Method 1 (LLM: Full Contract + Full ERC)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (3,0,3659)     |  (83, 5, 7381)   |  (16,0, 533)  |   (102,5,11573)   |
| ERC-721 | (0,0,108)     |  (0,0,195)   |  (0,0,17)  |   (0,0,320)   |  
| ERC-1155| (0,0,4)     |  (0,0,31)   |  (0,0,8)  |   (0,0,43)    |  
| Total   | (3,0,3771)	| (83,5,7607) |	(16,0,558) |	(102,5,11936) |

### Method 2 (LLM: Full Contract + Single Violated Rule)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (739, 1273)     |  (2037, 7788)   |  (823, 2789)  |   (3599, 11850)    |
| ERC-721 | (2, 185)     |  (1, 105)   |  (0, 33)  |   (3, 323)    |  
| ERC-1155| (4, 27)     |  (0, 30)   |  (0,0)  |   (4, 57)    |  
| Total   | (745, 1485) |	(2038, 7923) |	(823, 2822)	 | (3606, 12230) |

### Method 3 (LLM: Sliced Code + Single Violated Rule)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (1232, 780)     |  (8761, 1064)   |  (1794, 1818) |   (11787, 3662)    |
| ERC-721 | (84, 103)     |  (73, 33)   |  (3, 30)  |   (160, 166)    |  
| ERC-1155| (11, 20)     |  (24, 6)   |  (0,0)  |   (35, 26)   |  
| Total   | (1327, 903)	 | (8858, 1103)	 | (1797, 1848)	 | (11982, 3854) |



## Manual-Inspect Database Info

|      | call | emit | throw | interface | assign | return | total | # of contracts |
|------|------|------|-------|-----------|--------|--------|-------|---| 
| ERC-20  | 0    | 57    | 48     | 35         | 1      | 4      | 145     | 30|

### Method 1 (LLM: Full Contract + Full ERC)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (16,0,40)     |  (21, 0, 36)   |  (5,2, 6)  |   (42,2,82)   |

### Method 2 (LLM: Full Contract + Single Violated Rule)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (3, 18)     |  (29, 30)   |  (30, 35)  |   (62, 83)    |

### Method 3 (LLM: Sliced Code + Single Violated Rule)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (8, 13)     |  (48, 11)   |  (54, 11) |   (110, 35)    |

## Average Lines of Code
Manual-Inspect: 303.73
Err-Inj: 2972041 / 5347 = 555.83

## Average Errors
Manual-Inspect: 4.83
Err-Inj: 2.96

## How errors distribute across different security impacts

|         | high | medium | low | 
|------   |------|------|-------|
| Manual-Inspect | 9.4% | 29.2 % | 61.3 % |
| Err - Inj | 14.1% | 62.9% | 23.0% |