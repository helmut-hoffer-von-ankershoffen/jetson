import os, requests, json, encodings
from enum import Enum
from pydantic import BaseModel
from fastapi import APIRouter, HTTPException
from starlette.responses import Response
from starlette.status import HTTP_503_SERVICE_UNAVAILABLE, HTTP_500_INTERNAL_SERVER_ERROR

router = APIRouter()

model_name = os.environ['MODEL_NAME']

SERVING_HOST = 'localhost'
SERVING_REST_PORT = int(8501)
HEALTH_TIMEOUT = 5.0

class HealthEnum(str, Enum):
    ok = 'OK'
    error = 'ERROR'

class Response(BaseModel):
    health: HealthEnum = HealthEnum.ok
    message: str = None
    details: dict = None

@router.get(
    '/healthz',
    response_model = Response,
    operation_id = 'healthz',
    tags = [ 'health' ],
    summary = 'Health endpoint for Kubernetes',
    description = 'Checks health of webservice and TensorFlow Serving. Use in readiness and liveness probe configuration of your deployment.'
)
async def healthz():
    try:
        try:
            status_body = json.loads(
                requests
                    .get(
                        f"http://{SERVING_HOST}:{SERVING_REST_PORT}/v1/models/{model_name}",
                        timeout = HEALTH_TIMEOUT
                    )
                    .content
                    .decode(encodings.utf_8.getregentry().name)
                )
        except:
            return {
                'health': 'ERROR',
                'message': 'Could not reach TensorFlow Serving REST API',
                'details': None
            }
        available = (
            len(status_body['model_version_status']) > 0
            and status_body['model_version_status'][0]['state'] == 'AVAILABLE'
        )
        if available:
            return {
                'health': 'OK'
            }
        else:
            response.status_code = HTTP_503_SERVICE_UNAVAILABLE
            return {
                'health': 'ERROR',
                'message': f'Model {model_name} not available',
                'details': status_body
            }
    except:
        response.status_code = HTTP_500_INTERNAL_SERVER_ERROR
        return {
            'health': 'ERROR',
            'message': 'Internal error',
            'details': None
        }
