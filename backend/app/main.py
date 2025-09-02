from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import uvicorn
import os
from typing import Optional

from .api.routes import router as api_router
from .services.comfyui_service import ComfyUIService

# 创建 FastAPI 应用实例
app = FastAPI(
    title="FLUX Creator Desktop API",
    description="后端 API 服务，用于处理图像生成请求",
    version="1.0.0"
)

# 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",  # Vite 开发服务器
        "http://localhost:3000",  # React 开发服务器
        "https://*.railway.app",  # Railway 部署域名
        "https://*.onrender.com", # Render 部署域名
        "https://*.herokuapp.com", # Heroku 部署域名
        "*"  # 允许所有域名（生产环境可根据需要限制）
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 包含 API 路由
app.include_router(api_router, prefix="/api/v1")

# 全局异常处理
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    return JSONResponse(
        status_code=500,
        content={"detail": f"Internal server error: {str(exc)}"}
    )

# 健康检查端点
@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "FLUX Creator Desktop API is running"}

@app.get("/api/v1/health")
async def api_health_check():
    return {"status": "healthy", "message": "FLUX Creator Desktop API is running"}

# 根路径
@app.get("/")
async def root():
    return {
        "message": "Welcome to FLUX Creator Desktop API",
        "version": "1.0.0",
        "docs": "/docs"
    }

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )