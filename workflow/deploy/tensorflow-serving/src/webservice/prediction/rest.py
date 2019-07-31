import os, requests, json, encodings
from fastapi import APIRouter
from typing import List
from pydantic import BaseModel

router = APIRouter()

model_name = os.environ['MODEL_NAME']

SERVING_HOST = 'localhost'
SERVING_REST_PORT = int(8501)
PREDICT_TIMEOUT = 5.0

class Request(BaseModel):
    instances: List[float] = []

class Response(BaseModel):
    predictions: List[float] = []

@router.post(
    '/predict',
    response_model = Response,
    operation_id = 'restPredict',
    tags = [ 'prediction'  ],
    summary = 'Predict via REST',
    description = 'Predict given trained TensorFlow model. Accesses REST endpoint of TensorFlow Serving.'
)
async def restPredict(request: Request):
    return {
        'predictions': json.loads(
            requests
                .post(
                   f"http://{SERVING_HOST}:{SERVING_REST_PORT}/v1/models/{model_name}:predict",
                   json = request.dict(),
                   timeout = PREDICT_TIMEOUT
               )
               .content
               .decode(encodings.utf_8.getregentry().name)
            )['predictions']
    }
