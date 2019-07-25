import os, time, requests, json
from fastapi import FastAPI, HTTPException
from starlette.responses import Response
from starlette.status import HTTP_503_SERVICE_UNAVAILABLE

app = FastAPI()

model_name = os.environ['MODEL_NAME']

@app.get("/health")
def handle(response: Response):
    try:
        try:
            status_body = json.loads(
                requests
                    .get(f'http://localhost:8501/v1/models/{model_name}')
                    .content
                    .decode('utf-8')
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
        response.status_code = HTTP_503_SERVICE_UNAVAILABLE
        return {
            'health': 'ERROR',
            'message': 'Internal error',
            'details': None
        }

@app.post("/predict")
def handle():
    return json.loads(
        requests
            .post(
               f'http://localhost:8501/v1/models/{model_name}:predict',
               json = {
                  'instances': [
                      1.0,
                      2.0,
                      5.0
                  ]
              }
           )
           .content
           .decode('utf-8')
        )['predictions']
