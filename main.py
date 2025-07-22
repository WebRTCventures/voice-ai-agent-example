import json
import os

from fastapi import FastAPI, WebSocket, Request
from fastapi.middleware.cors import CORSMiddleware
from starlette.responses import HTMLResponse
from loguru import logger

from bot import main

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for testing
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/")
async def start_call(request: Request):
    logger.info("Received POST request for TwiML")
    
    # Use environment variable if set, otherwise construct from request
    ws_url = os.getenv("WEBSOCKET_URL")
    if not ws_url:
        forwarded_proto = request.headers.get("x-forwarded-proto")
        is_https = forwarded_proto == "https" or request.url.scheme == "https"
        scheme = "wss" if is_https else "ws"
        host = request.headers.get('host')
        ws_url = f"{scheme}://{host}/ws"
    logger.info(f"Generated WebSocket URL: {ws_url}")
    xml_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Connect>
    <Stream url="{ws_url}"></Stream>
  </Connect>
  <Pause length="40"/>
</Response>'''
    return HTMLResponse(content=xml_content, media_type="application/xml")


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    logger.info("WebSocket connection accepted")
    start_data = websocket.iter_text()
    await start_data.__anext__()
    call_data = json.loads(await start_data.__anext__())
    stream_sid = call_data["start"]["streamSid"]
    logger.info(f"Starting voice AI session with stream_sid: {stream_sid}")
    await main(websocket, stream_sid)