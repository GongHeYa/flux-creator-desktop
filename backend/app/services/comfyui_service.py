import json
import requests
import asyncio
import aiohttp
import random
from typing import Dict, Any, Optional, Callable
import os
from datetime import datetime

class ComfyUIService:
    """
    ComfyUI 服务类，负责与 ComfyUI API 交互
    """
    
    def __init__(self, comfyui_url: str = "http://127.0.0.1:7860"):
        self.comfyui_url = comfyui_url
        self.workflow_template = None
        self.load_workflow_template()
    
    def load_workflow_template(self):
        """
        加载 ComfyUI 工作流模板
        """
        try:
            # 加载 API 工作流文件
            workflow_path = "/root/GengZhe T2I/flux1_krea_dev【API】.json"
            with open(workflow_path, 'r', encoding='utf-8') as f:
                self.workflow_template = json.load(f)
            print(f"成功加载工作流模板: {workflow_path}")
        except Exception as e:
            print(f"加载工作流模板失败: {str(e)}")
            # 使用默认模板
            self.workflow_template = self._get_default_workflow()
    
    def _get_default_workflow(self) -> Dict[str, Any]:
        """
        获取默认工作流模板
        """
        return {
            "8": {
                "inputs": {
                    "samples": ["31", 0],
                    "vae": ["39", 0]
                },
                "class_type": "VAEDecode",
                "_meta": {"title": "VAE解码"}
            },
            "9": {
                "inputs": {
                    "filename_prefix": "flux_krea/flux_krea",
                    "images": ["8", 0]
                },
                "class_type": "SaveImage",
                "_meta": {"title": "保存图像"}
            },
            "27": {
                "inputs": {
                    "width": 1024,
                    "height": 1024,
                    "batch_size": 1
                },
                "class_type": "EmptySD3LatentImage",
                "_meta": {"title": "空Latent图像（SD3）"}
            },
            "31": {
                "inputs": {
                    "seed": 674476469314237,
                    "steps": 20,
                    "cfg": 1,
                    "sampler_name": "euler",
                    "scheduler": "simple",
                    "denoise": 1,
                    "model": ["38", 0],
                    "positive": ["45", 0],
                    "negative": ["42", 0],
                    "latent_image": ["27", 0]
                },
                "class_type": "KSampler",
                "_meta": {"title": "K采样器"}
            },
            "38": {
                "inputs": {
                    "unet_name": "flux1-krea-dev.safetensors",
                    "weight_dtype": "default"
                },
                "class_type": "UNETLoader",
                "_meta": {"title": "UNet加载器"}
            },
            "39": {
                "inputs": {
                    "vae_name": "ae.safetensors"
                },
                "class_type": "VAELoader",
                "_meta": {"title": "加载VAE"}
            },
            "40": {
                "inputs": {
                    "clip_name1": "clip_l.safetensors",
                    "clip_name2": "t5xxl_fp16.safetensors",
                    "type": "flux",
                    "device": "default"
                },
                "class_type": "DualCLIPLoader",
                "_meta": {"title": "双CLIP加载器"}
            },
            "42": {
                "inputs": {
                    "conditioning": ["45", 0]
                },
                "class_type": "ConditioningZeroOut",
                "_meta": {"title": "条件零化"}
            },
            "45": {
                "inputs": {
                    "text": "Highly realistic portrait of a Nordic woman with blonde hair and blue eyes, very few freckles on her face, gaze sharp and intellectual. The lighting should reflect the unique coolness of Northern Europe. Outfit is minimalist and modern, background is blurred in cool tones. Needs to perfectly capture the characteristics of a Scandinavian woman. solo, Centered composition\n",
                    "speak_and_recognation": {"__value__": [False, True]},
                    "clip": ["40", 0]
                },
                "class_type": "CLIPTextEncode",
                "_meta": {"title": "CLIP文本编码"}
            }
        }
    
    def prepare_workflow(self, prompt: str, width: int = 1024, height: int = 1024, 
                        steps: int = 20, cfg: float = 1.0, seed: Optional[int] = None,
                        sampler_name: str = "euler", scheduler: str = "simple") -> Dict[str, Any]:
        """
        准备工作流，根据参数修改模板
        """
        if not self.workflow_template:
            raise Exception("工作流模板未加载")
        
        # 深拷贝模板
        import copy
        workflow = copy.deepcopy(self.workflow_template)
        
        # 生成随机种子
        if seed is None or seed < 0:
            seed = random.randint(0, 2**32 - 1)
        
        # 根据实际工作流结构更新参数
        # 节点45: CLIP文本编码 - 更新提示词
        if "45" in workflow:
            workflow["45"]["inputs"]["text"] = prompt
            # 保持其他参数不变
            if "speak_and_recognation" not in workflow["45"]["inputs"]:
                workflow["45"]["inputs"]["speak_and_recognation"] = {"__value__": [False, True]}
        
        # 节点31: K采样器 - 更新采样参数
        if "31" in workflow:
            workflow["31"]["inputs"]["seed"] = seed
            workflow["31"]["inputs"]["steps"] = steps
            workflow["31"]["inputs"]["cfg"] = cfg
            # sampler_name 和 scheduler 使用工作流默认值
        
        # 节点27: 空Latent图像 - 更新图像尺寸
        if "27" in workflow:
            workflow["27"]["inputs"]["width"] = width
            workflow["27"]["inputs"]["height"] = height
        
        # 节点9: 保存图像 - 设置输出文件名
        if "9" in workflow:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            workflow["9"]["inputs"]["filename_prefix"] = f"flux_krea/flux_krea_{timestamp}"
        
        return workflow
    
    async def generate_image(self, prompt: str, width: int = 1024, height: int = 1024,
                           steps: int = 20, cfg: float = 1.0, seed: Optional[int] = None,
                           sampler_name: str = "euler", scheduler: str = "simple",
                           task_id: str = None, progress_callback: Optional[Callable] = None) -> Dict[str, Any]:
        """
        生成图像的主要方法
        """
        try:
            # 准备工作流
            workflow = self.prepare_workflow(
                prompt=prompt, width=width, height=height,
                steps=steps, cfg=cfg, seed=seed,
                sampler_name=sampler_name, scheduler=scheduler
            )
            
            if progress_callback:
                progress_callback(0.2)
            
            # 发送工作流到 ComfyUI
            result = await self._execute_workflow(workflow, progress_callback)
            
            if progress_callback:
                progress_callback(1.0)
            
            return {
                "success": True,
                "images": result.get("images", []),
                "workflow_id": result.get("workflow_id"),
                "seed": seed,
                "prompt": prompt
            }
            
        except Exception as e:
            print(f"图像生成失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "prompt": prompt
            }
    
    async def _execute_workflow(self, workflow: Dict[str, Any], progress_callback: Optional[Callable] = None) -> Dict[str, Any]:
        """
        执行工作流
        """
        try:
            # 检查 ComfyUI 服务状态
            status_ok = await self._check_comfyui_status()
            print(f"ComfyUI 状态检查结果: {status_ok}")
            if not status_ok:
                print("ComfyUI 服务不可用，使用模拟生成")
                return await self._simulate_generation(progress_callback)
            
            async with aiohttp.ClientSession() as session:
                # 提交工作流
                print(f"正在提交工作流到 {self.comfyui_url}/prompt")
                async with session.post(
                    f"{self.comfyui_url}/prompt",
                    json={"prompt": workflow},
                    timeout=30
                ) as response:
                    response_text = await response.text()
                    print(f"ComfyUI 响应状态: {response.status}")
                    print(f"ComfyUI 响应内容: {response_text}")
                    
                    if response.status != 200:
                        raise Exception(f"提交工作流失败: {response.status}, 响应: {response_text}")
                    
                    result = await response.json()
                    prompt_id = result.get("prompt_id")
                    
                    if not prompt_id:
                        raise Exception(f"未获取到 prompt_id, 响应: {result}")
                    
                    if progress_callback:
                        progress_callback(0.3)
                    
                    # 等待生成完成
                    return await self._wait_for_completion(prompt_id, progress_callback)
                    
        except Exception as e:
            print(f"执行工作流时出错: {str(e)}")
            # 如果出错，返回模拟结果
            return await self._simulate_generation(progress_callback)
    
    async def _check_comfyui_status(self) -> bool:
        """
        检查 ComfyUI 服务状态
        """
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(
                    f"{self.comfyui_url}/system_stats",
                    timeout=5
                ) as response:
                    return response.status == 200
        except:
            return False
    
    async def _wait_for_completion(self, prompt_id: str, progress_callback: Optional[Callable] = None) -> Dict[str, Any]:
        """
        等待生成完成
        """
        max_wait_time = 300  # 最大等待时间 5 分钟
        check_interval = 2   # 检查间隔 2 秒
        elapsed_time = 0
        
        while elapsed_time < max_wait_time:
            try:
                async with aiohttp.ClientSession() as session:
                    # 检查队列状态
                    async with session.get(f"{self.comfyui_url}/queue") as response:
                        if response.status == 200:
                            queue_data = await response.json()
                            
                            # 检查是否完成
                            if not self._is_in_queue(prompt_id, queue_data):
                                # 获取生成结果
                                return await self._get_generation_result(prompt_id)
                    
                    # 更新进度
                    if progress_callback:
                        progress = 0.3 + (elapsed_time / max_wait_time) * 0.6
                        progress_callback(min(progress, 0.9))
                    
                    await asyncio.sleep(check_interval)
                    elapsed_time += check_interval
                    
            except Exception as e:
                print(f"检查生成状态时出错: {str(e)}")
                break
        
        raise Exception("生成超时")
    
    def _is_in_queue(self, prompt_id: str, queue_data: Dict) -> bool:
        """
        检查 prompt_id 是否还在队列中
        """
        try:
            running = queue_data.get("queue_running", [])
            pending = queue_data.get("queue_pending", [])
            
            for item in running + pending:
                if len(item) > 1 and item[1] == prompt_id:
                    return True
            return False
        except:
            return True
    
    async def _get_generation_result(self, prompt_id: str) -> Dict[str, Any]:
        """
        获取生成结果
        """
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(f"{self.comfyui_url}/history/{prompt_id}") as response:
                    if response.status == 200:
                        history = await response.json()
                        
                        if prompt_id in history:
                            outputs = history[prompt_id].get("outputs", {})
                            images = []
                            
                            # 提取图像信息
                            for node_id, output in outputs.items():
                                if "images" in output:
                                    for img_info in output["images"]:
                                        filename = img_info.get("filename")
                                        subfolder = img_info.get("subfolder", "")
                                        img_type = img_info.get("type", "output")
                                        
                                        # 使用后端代理 URL
                                        backend_url = f"http://localhost:8000/api/v1/image/{filename}?subfolder={subfolder}&type={img_type}"
                                        
                                        images.append({
                                            "filename": filename,
                                            "subfolder": subfolder,
                                            "type": img_type,
                                            "url": backend_url
                                        })
                            
                            return {
                                "workflow_id": prompt_id,
                                "images": images
                            }
            
            raise Exception("未找到生成结果")
            
        except Exception as e:
            print(f"获取生成结果时出错: {str(e)}")
            raise
    
    async def _simulate_generation(self, progress_callback: Optional[Callable] = None) -> Dict[str, Any]:
        """
        模拟图像生成（当 ComfyUI 不可用时）
        """
        print("ComfyUI 服务不可用，使用模拟生成")
        
        # 模拟生成过程
        for i in range(10):
            if progress_callback:
                progress_callback(0.3 + (i / 10) * 0.6)
            await asyncio.sleep(0.5)
        
        # 返回模拟结果
        return {
            "workflow_id": "simulated_" + str(random.randint(1000, 9999)),
            "images": [{
                "filename": "simulated_image.png",
                "subfolder": "simulated",
                "type": "output",
                "url": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDUxMiA1MTIiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiBmaWxsPSIjZjBmMGYwIi8+Cjx0ZXh0IHg9IjI1NiIgeT0iMjU2IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBkb21pbmFudC1iYXNlbGluZT0iY2VudHJhbCIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjI0IiBmaWxsPSIjNjY2Ij7mqKHmi5/nlJ/miJDnmoTlm77lg48gKENvbWZ5VUkg5pyN5Yqh5LiN5Y+v55SoKTwvdGV4dD4KPHN2Zz4="
            }]
        }