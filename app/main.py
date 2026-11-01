from fastapi import FastAPI
import time
import asyncio
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

app = FastAPI()


@app.get("/api/test")
async def root():
    logger.info("Request received")
    start = time.perf_counter()
    await asyncio.sleep(0.1)
    end = time.perf_counter()
    processing_time_ms = (end - start) * 1000
    logger.info("Request completed: %s", processing_time_ms)
    return {
        "status" : "success" ,
        "message": "Request processed",
        "processing_time_ms" :  round(processing_time_ms, 2)
            }