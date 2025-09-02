import os
import base64
import aiofiles
from PIL import Image
import io
from typing import Optional, Dict, Any
import aiohttp
from datetime import datetime

class ImageService:
    """
    图像服务类，负责图像处理和存储
    """
    
    def __init__(self, output_dir: str = "/tmp/flux_images"):
        self.output_dir = output_dir
        self.ensure_output_dir()
    
    def ensure_output_dir(self):
        """
        确保输出目录存在
        """
        try:
            os.makedirs(self.output_dir, exist_ok=True)
            print(f"图像输出目录: {self.output_dir}")
        except Exception as e:
            print(f"创建输出目录失败: {str(e)}")
    
    async def download_image(self, image_url: str, filename: str = None) -> Optional[str]:
        """
        从 URL 下载图像并保存到本地
        """
        try:
            if not filename:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"image_{timestamp}.png"
            
            file_path = os.path.join(self.output_dir, filename)
            
            async with aiohttp.ClientSession() as session:
                async with session.get(image_url) as response:
                    if response.status == 200:
                        content = await response.read()
                        
                        async with aiofiles.open(file_path, 'wb') as f:
                            await f.write(content)
                        
                        print(f"图像已保存: {file_path}")
                        return file_path
                    else:
                        print(f"下载图像失败: HTTP {response.status}")
                        return None
                        
        except Exception as e:
            print(f"下载图像时出错: {str(e)}")
            return None
    
    async def image_to_base64(self, image_path: str) -> Optional[str]:
        """
        将图像文件转换为 base64 编码
        """
        try:
            async with aiofiles.open(image_path, 'rb') as f:
                image_data = await f.read()
                base64_data = base64.b64encode(image_data).decode('utf-8')
                return f"data:image/png;base64,{base64_data}"
        except Exception as e:
            print(f"转换图像为 base64 时出错: {str(e)}")
            return None
    
    def resize_image(self, image_path: str, max_width: int = 1024, max_height: int = 1024) -> Optional[str]:
        """
        调整图像大小
        """
        try:
            with Image.open(image_path) as img:
                # 计算新尺寸
                width, height = img.size
                ratio = min(max_width / width, max_height / height)
                
                if ratio < 1:
                    new_width = int(width * ratio)
                    new_height = int(height * ratio)
                    
                    # 调整大小
                    resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                    
                    # 保存调整后的图像
                    resized_path = image_path.replace('.png', '_resized.png')
                    resized_img.save(resized_path, 'PNG')
                    
                    return resized_path
                else:
                    return image_path
                    
        except Exception as e:
            print(f"调整图像大小时出错: {str(e)}")
            return None
    
    def get_image_info(self, image_path: str) -> Optional[Dict[str, Any]]:
        """
        获取图像信息
        """
        try:
            with Image.open(image_path) as img:
                return {
                    "width": img.width,
                    "height": img.height,
                    "format": img.format,
                    "mode": img.mode,
                    "size_bytes": os.path.getsize(image_path)
                }
        except Exception as e:
            print(f"获取图像信息时出错: {str(e)}")
            return None
    
    async def process_generated_images(self, images_info: list) -> list:
        """
        处理生成的图像列表
        """
        processed_images = []
        
        for img_info in images_info:
            try:
                # 如果是 URL，下载图像
                if 'url' in img_info:
                    local_path = await self.download_image(
                        img_info['url'], 
                        img_info.get('filename', None)
                    )
                    
                    if local_path:
                        # 转换为 base64
                        base64_data = await self.image_to_base64(local_path)
                        
                        if base64_data:
                            processed_images.append({
                                "filename": img_info.get('filename'),
                                "local_path": local_path,
                                "base64": base64_data,
                                "info": self.get_image_info(local_path)
                            })
                
                # 如果已经是本地路径
                elif 'local_path' in img_info:
                    base64_data = await self.image_to_base64(img_info['local_path'])
                    
                    if base64_data:
                        processed_images.append({
                            "filename": os.path.basename(img_info['local_path']),
                            "local_path": img_info['local_path'],
                            "base64": base64_data,
                            "info": self.get_image_info(img_info['local_path'])
                        })
                        
            except Exception as e:
                print(f"处理图像时出错: {str(e)}")
                continue
        
        return processed_images
    
    def cleanup_old_images(self, max_age_hours: int = 24):
        """
        清理旧的图像文件
        """
        try:
            import time
            current_time = time.time()
            max_age_seconds = max_age_hours * 3600
            
            for filename in os.listdir(self.output_dir):
                file_path = os.path.join(self.output_dir, filename)
                
                if os.path.isfile(file_path):
                    file_age = current_time - os.path.getmtime(file_path)
                    
                    if file_age > max_age_seconds:
                        os.remove(file_path)
                        print(f"已删除旧图像: {filename}")
                        
        except Exception as e:
            print(f"清理旧图像时出错: {str(e)}")