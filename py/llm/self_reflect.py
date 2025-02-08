
# Define the types for the callable parameters
from abc import ABC, abstractmethod
from dataclasses import dataclass
import json
from typing import Callable, List, Tuple, TypeVar, Generic

from llm.adapters import LLMAdapter
from llm.utils import trim_json_markers

T = TypeVar('T')  # Generic type for the seed
R = TypeVar('R')  # Generic type for the result
FB = TypeVar('FB')  # Generic type for feedback
RCTX = TypeVar('RCTX')  # Generic type for context used in test

RunFunction = Callable[[object, T, RCTX], R]
IsPassedFunction = Callable[[RCTX, R], bool]
MutateFunction = Callable[[object, T, List[FB]], List[T]]
FeedbackFunction = Callable[[object, RCTX, R], FB]

@dataclass
class SelfReflectSeed:
    seed: T
    num_of_passed: int
    
class SelfReflect(ABC):

    def __init__(self, llm_adapter: LLMAdapter) -> None:
        super().__init__()
        self._llm_adapter = llm_adapter

    @abstractmethod
    def run(self, seed:T, rctx:RCTX) -> R:
        raise NotImplementedError()
    
    @abstractmethod
    def is_passed(self, rctx:RCTX, res: R) -> bool:
        raise NotImplementedError()

    @abstractmethod
    def mutate(self, seed:T, fbs:List[FB]) -> List[T]:
        raise NotImplementedError()
    
    @abstractmethod
    def feedback(self, rctx:RCTX, res: R) -> FB:
        raise NotImplementedError()
    
    
    def self_reflect(self, initial:T, test_datas:List[RCTX], max_cycle = 3, max_llm_ask = 20) -> Tuple[T, int]:
        cycle = 0
        ask = 0
        seeds:List[SelfReflectSeed] = [SelfReflectSeed(seed=initial, num_of_passed=0)]

        while True:
            if cycle >= max_cycle:
                break
            if ask >= max_llm_ask:
                break

            interesting_seeds_to_add = []
            for seed in seeds:
                fbs = []
                not_passed_cnt = 0
                for rctx in test_datas:
                    try:
                        run = self.run(seed.seed, rctx)
                        ask += 1
                        if self.is_passed(rctx, run):
                            continue
                    except Exception as err:
                        print(f"is pass error: {str(err)}")
                        continue
                    not_passed_cnt += 1
                    feedback = self.feedback(rctx, run)
                    fbs.append(feedback)
                
                if not_passed_cnt == 0:
                    seed.num_of_passed = len(test_datas)
                    return seed.seed, seed.num_of_passed

                print(f"{not_passed_cnt}/{len(test_datas)} not passed")
                seed.num_of_passed = len(test_datas) - not_passed_cnt
                

                new_seeds = self.mutate(seed.seed, fbs)
                interesting_seeds_to_add.extend([SelfReflectSeed(seed=new_seed, num_of_passed=0) for new_seed in new_seeds])

            if interesting_seeds_to_add:
                seeds = interesting_seeds_to_add + seeds
            cycle += 1
        seeds.sort(key=lambda s:s.num_of_passed,reverse=True)
        return seeds[0].seed, seeds[0].num_of_passed


@dataclass
class AuditInstSelfReflectRunContext:
    expect_violate: bool
    code: str
    rule: str


class AuditInstSelfReflect(SelfReflect):
    def run(self, seed: T, rctx: AuditInstSelfReflectRunContext) -> R:
        prompt = f"""
Rule:\"\"\"
{seed}
\"\"\"
Return a JSON object with keys 'compliant' (boolean) indicating whether the code follows the rule, and 'reason' (string) providing an explanation if it does not."
Code:\"\"\"
{rctx.code}
\"\"\""""
        res =  self._llm_adapter.single(prompt)[0]
        return json.loads(trim_json_markers(res))

    def mutate(self, seed: T, fbs: List[FB]) -> List[T]:
        prompt = f"""
You are writing an instruction for the prompt to test whether a code violates the rule. 
By given the existing instruction:\"\"\"{seed}\"\"\", generate the new instruction based on the given feedbacks.
Feedbacks:\"\"\"
{"\n".join(fbs)}
\"\"\"
Return only the new instruction, without double quotes.
        """
        return self._llm_adapter.single(prompt, n=3)

    def is_passed(self, rctx: AuditInstSelfReflectRunContext, res: R) -> bool:
        return (not rctx.expect_violate) == res["compliant"]
    
    def feedback(self, rctx: AuditInstSelfReflectRunContext, res: R) -> FB:
        verb = "violates" if rctx.expect_violate else { "does not violate"}
        
        prompt = f"""
Code:\"\"\"
{rctx.code}
\"\"\"
Rule:\"\"\"
{rctx.rule}
\"\"\"
Incorrect analysis:
\"\"\"
{res}
\"\"\"
In fact, the given code {verb} the given rule. 
Summary in one sentence why the analysis wrong and the sentence will be added into the prompt next time to avoid the same mistake.
        """
        
        return self._llm_adapter.single(prompt)[0]
        