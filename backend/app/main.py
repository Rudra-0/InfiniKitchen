from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import api_router

app = FastAPI(
    title="InfiniKitchen API",
    description="Backend for Generative Gastronomy Sandbox",
    version="0.1.0",
)

# CORS Configuration
origins = [
    "http://localhost",
    "http://localhost:3000",
    "*",  # Allow all for development; restrict in production
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")

@app.get("/health")
async def health_check():
    return {
        "status": "ok",
        "service": "infinikitchen-api",
        "version": "0.1.0"
    }

@app.get("/")
async def root():
    return {"message": "Welcome to InfiniKitchen API"}
