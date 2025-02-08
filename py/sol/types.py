from typing import List, Optional, TypedDict


class FunctionArgType(TypedDict):
    name: str
    type: str

class EventArgType(TypedDict):
    name: str
    type: str
    indexed: bool
    
class SolidityFunctionFormat(TypedDict):
    arg_types:List[FunctionArgType]
    return_type: Optional[FunctionArgType]
    optional: bool
    view: bool
    pure: bool
    payable: bool
    name: str
    
class SolidityEventFormat(TypedDict):
    name: str
    arg_types:List[EventArgType]