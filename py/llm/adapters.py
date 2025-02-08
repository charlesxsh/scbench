from abc import ABC, abstractmethod
import json
import os
from typing import List
import openai
import uuid
from log import get_private_file_logger

llm_logger = get_private_file_logger("llm.log")

class LLMAdapter(ABC):
    @abstractmethod
    def ask(self, prompts, temperature:float, n:int, log_label=None) -> List[str]:
        raise NotImplementedError()
    
    def single(self, prompt:str, temperature:float=0.7, n:int=1, model = None, log_label=None) -> List[str]:
        return self.ask([{"content":prompt, "role":"user"}], temperature=temperature, n=n, model=model, log_label=log_label)


class OpenAILLMAdapter(LLMAdapter):
    def __init__(self, openai_key=None, model = None, log_label=None) -> None:
        super().__init__()
        openai_key = openai_key if openai_key else os.environ.get("OPENAI_API_KEY")
        self._client = openai.OpenAI(
            api_key=openai_key
        )
        self._model = model if model else "gpt-3.5-turbo"

    def ask(self, prompts, temperature:float = 0, n:int = 1, model = None, log_label=None) -> List[str]:
        id = str(uuid.uuid4())
        prompts_str = ""
        for p in prompts:
            prompts_str += f"{p['role']}:\n{p['content']}\n"
        llm_logger.info(f"ID={id} Label={log_label}\nPrompt=\n{prompts_str}")
        model = model if model else self._model
        response = self._client.chat.completions.create(
            model=model,
            temperature=temperature, 
            n=n,
            messages=prompts
        )
        
        replies = [choice.message.content for choice in response.choices]
        replies_str = ""
        for idx, r in enumerate(replies):
            replies_str += f"{idx}:\n{r}\n"
        llm_logger.info(f"ID={id} Label={log_label}\nReplies=\n{replies_str}")
        return replies


