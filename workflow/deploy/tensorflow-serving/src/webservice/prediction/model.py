from pydantic import BaseModel
from typing import List

class Request(BaseModel):
    instances: List[float] = []

class ResponseMeta(BaseModel):
    model_name: str
    jetson_model: str
    duration: int   # milliseconds
    timestamp: int

class Response(BaseModel):
    predictions: List[float] = []
    meta: ResponseMeta
