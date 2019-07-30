from fastapi import FastAPI
from .health import healthz
from .prediction import rest, grpc

app = FastAPI(
    title = 'TensorFlow Serving webservice ',
    description = 'Webservice acting as facade of TensorFlow Serving',
    openapi_url = '/api/v1/openapi.json',
    docs_url = '/docs',
    redoc = '/redoc'
)

app.include_router(
    healthz.router,
    prefix='/api/v1/health'
)

app.include_router(
    rest.router,
    prefix='/api/v1/prediction'
)

app.include_router(
    grpc.router,
    prefix='/api/v1/prediction/grpc'
)
