import os, grpc, datetime
from fastapi import APIRouter
from tensorflow.core.framework import types_pb2
from tensorflow.contrib.util import make_tensor_proto
from tensorflow_serving.apis import predict_pb2
from tensorflow_serving.apis import prediction_service_pb2_grpc
from webservice.prediction import model
from webservice.util import util

router = APIRouter()

model_name = os.environ['MODEL_NAME']
jetson_model = os.environ['JETSON_MODEL']

SERVING_HOST = 'localhost'
SERVING_GRPC_PORT = int(8500)
PREDICT_TIMEOUT = 5.0

@router.post(
    '/predict',
    response_model = model.Response,
    operation_id = 'gRPCPredict',
    tags = [ 'prediction' ],
    summary = 'Predict via gRPC',
    description = 'Predict given trained TensorFlow model. Accesses gRPC endpoint of TensorFlow Serving.'
)
async def gRPCPredict(request: model.Request):
    start = datetime.datetime.now()
    stub = prediction_service_pb2_grpc.PredictionServiceStub(
        grpc.insecure_channel(f"{SERVING_HOST}:{SERVING_GRPC_PORT}")
    )
    predictRequest = predict_pb2.PredictRequest()
    predictRequest.model_spec.name = model_name
    predictRequest.inputs['x'].CopyFrom(
        make_tensor_proto(
            request.instances,
            shape = [len(request.instances), 1]
        )
    )
    predictResult = stub.Predict(predictRequest, PREDICT_TIMEOUT)
    return {
        'predictions': list(predictResult.outputs['y'].float_val),
        'meta': {
            'model_name': model_name,
            'duration': util.millis_interval(start,datetime.datetime.now()),
            'timestamp': datetime.datetime.now().timestamp(),
            'jetson_model': jetson_model
        }
    }
