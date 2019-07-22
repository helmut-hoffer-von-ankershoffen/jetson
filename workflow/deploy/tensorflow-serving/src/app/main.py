from fastapi import FastAPI
import time

app = FastAPI()

@app.get("/predict")
@app.post("/predict")
def handle():
    return {"Prediction": "Done"}