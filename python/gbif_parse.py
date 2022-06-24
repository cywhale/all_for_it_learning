# A simple example to test pytaxize and web api

from typing import Union
from fastapi import FastAPI
from pytaxize import gbif

app = FastAPI()

@app.get("/")
def hello():
    return {"Hello": "World"}


@app.get("/sp")
def parse(q: Union[str, None] = None):
    return gbif.parse(name=[q])
