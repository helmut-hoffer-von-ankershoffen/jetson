import os, requests, datetime, json, encodings
from fastapi import APIRouter
from webservice.prediction import model
from webservice.util import util

router = APIRouter()

model_name = os.environ['MODEL_NAME']
jetson_model = os.environ['JETSON_MODEL']

SERVING_HOST = 'localhost'
SERVING_REST_PORT = int(8501)
PREDICT_TIMEOUT = 5.0

@router.post(
    '/predict',
    response_model = model.Response,
    operation_id = 'restPredict',
    tags = [ 'prediction' ],
    summary = 'Predict via REST',
    description = 'Predict given trained TensorFlow model. Accesses REST endpoint of TensorFlow Serving.'
)
async def restPredict(request: model.Request):
    start = datetime.datetime.now()
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
            )['predictions'],
        'meta': {
            'model_name': model_name,
            'duration': util.millis_interval(start,datetime.datetime.now()),
            'timestamp': datetime.datetime.now().timestamp(),
            'jetson_model':  jetson_model
        }
    }
