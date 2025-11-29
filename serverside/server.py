import asyncio
import websockets
import json
from dotenv import load_dotenv
import os

load_dotenv()  
PORT=os.getenv("PORT")

CONNECTED_CLIENTS = set()

async def handler(websocket, path):
    CONNECTED_CLIENTS.add(websocket)
    print(f"[SERVER] Client connected. Total: {len(CONNECTED_CLIENTS)}")
    
    try:
        async for message in websocket:
            for client in CONNECTED_CLIENTS:
                if client != websocket:
                    await client.send(message)

    except websockets.exceptions.ConnectionClosed:
        pass
    finally:
        CONNECTED_CLIENTS.remove(websocket)
        print(f"[SERVER] Client disconnected. Total: {len(CONNECTED_CLIENTS)}")


async def main():
    print(f"[SERVER] Starting WebSocket Server on port {PORT}...")
    async with websockets.serve(handler, "0.0.0.0", PORT):
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())
