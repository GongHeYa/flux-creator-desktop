from fastapi import APIRouter, HTTPException, BackgroundTasks
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Optional, Dict, Any
import asyncio
import uuid
import aiohttp
from datetime import datetime

from services.comfyui_service import ComfyUIService
from services.image_service import ImageService

router = APIRouter()

# 请求模型
class ImageGenerationRequest(BaseModel):
    prompt: str
    width: Optional[int] = 1024
    height: Optional[int] = 1024
    steps: Optional[int] = 20
    cfg: Optional[float] = 1.0
    seed: Optional[int] = None
    sampler_name: Optional[str] = "euler"
    scheduler: Optional[str] = "simple"

# 响应模型
class ImageGenerationResponse(BaseModel):
    task_id: str
    status: str
    message: str

class TaskStatusResponse(BaseModel):
    task_id: str
    status: str
    progress: Optional[float] = None
    result: Optional[Dict[str, Any]] = None
    error: Optional[str] = None

# 初始化服务
comfyui_service = ComfyUIService()
image_service = ImageService()

# 存储任务状态
tasks_status = {}

@router.post("/generate", response_model=ImageGenerationResponse)
async def generate_image(request: ImageGenerationRequest, background_tasks: BackgroundTasks):
    """
    生成图像的主要端点
    """
    try:
        # 生成唯一任务ID
        task_id = str(uuid.uuid4())
        
        # 初始化任务状态
        tasks_status[task_id] = {
            "status": "pending",
            "progress": 0.0,
            "created_at": datetime.now(),
            "result": None,
            "error": None
        }
        
        # 在后台执行图像生成
        background_tasks.add_task(
            process_image_generation,
            task_id,
            request
        )
        
        return ImageGenerationResponse(
            task_id=task_id,
            status="pending",
            message="图像生成任务已启动"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"启动图像生成失败: {str(e)}")

@router.get("/task/{task_id}", response_model=TaskStatusResponse)
async def get_task_status(task_id: str):
    """
    获取任务状态
    """
    if task_id not in tasks_status:
        raise HTTPException(status_code=404, detail="任务不存在")
    
    task = tasks_status[task_id]
    return TaskStatusResponse(
        task_id=task_id,
        status=task["status"],
        progress=task["progress"],
        result=task["result"],
        error=task["error"]
    )

@router.get("/tasks")
async def list_tasks():
    """
    列出所有任务
    """
    return {
        "tasks": [
            {
                "task_id": task_id,
                "status": task_info["status"],
                "progress": task_info["progress"],
                "created_at": task_info["created_at"].isoformat()
            }
            for task_id, task_info in tasks_status.items()
        ]
    }

async def process_image_generation(task_id: str, request: ImageGenerationRequest):
    """
    处理图像生成的后台任务
    """
    try:
        # 更新状态为处理中
        tasks_status[task_id]["status"] = "processing"
        tasks_status[task_id]["progress"] = 0.1
        
        # 调用 ComfyUI 服务生成图像
        result = await comfyui_service.generate_image(
            prompt=request.prompt,
            width=request.width,
            height=request.height,
            steps=request.steps,
            cfg=request.cfg,
            seed=request.seed,
            sampler_name=request.sampler_name,
            scheduler=request.scheduler,
            task_id=task_id,
            progress_callback=lambda progress: update_task_progress(task_id, progress)
        )
        
        # 更新任务状态为完成
        tasks_status[task_id]["status"] = "completed"
        tasks_status[task_id]["progress"] = 1.0
        tasks_status[task_id]["result"] = result
        
    except Exception as e:
        # 更新任务状态为失败
        tasks_status[task_id]["status"] = "failed"
        tasks_status[task_id]["error"] = str(e)
        print(f"图像生成失败 (任务 {task_id}): {str(e)}")

def update_task_progress(task_id: str, progress: float):
    """更新任务进度"""
    if task_id in tasks_status:
        tasks_status[task_id]["progress"] = progress

@router.get("/image/{filename}")
async def get_image(filename: str, subfolder: str = "", type: str = "output"):
    """
    代理访问 ComfyUI 生成的图像
    """
    try:
        comfyui_url = "http://127.0.0.1:7860"
        image_url = f"{comfyui_url}/view?filename={filename}&subfolder={subfolder}&type={type}"
        
        async with aiohttp.ClientSession() as session:
            async with session.get(image_url) as response:
                if response.status == 200:
                    content = await response.read()
                    content_type = response.headers.get('content-type', 'image/png')
                    
                    return StreamingResponse(
                        iter([content]),
                        media_type=content_type,
                        headers={"Content-Disposition": f"inline; filename={filename}"}
                    )
                else:
                    raise HTTPException(status_code=404, detail="Image not found")
                    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching image: {str(e)}")