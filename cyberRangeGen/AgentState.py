from typing import TypedDict, Annotated, Any


def add_messages(left: list, right: list):
    """Add-don't-overwrite."""
    return left + right


def update(a: Any, b:Any):
    return a

class BuilderAgentState(TypedDict):
    messages: Annotated[list, add_messages]
    llm: Annotated[any, update]