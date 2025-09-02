#!/bin/bash

# Google Cloud Run 自动部署脚本
# 使用方法: ./deploy-gcp.sh YOUR_PROJECT_ID [REGION]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [ $# -lt 1 ]; then
    print_error "使用方法: $0 PROJECT_ID [REGION]"
    print_info "示例: $0 my-project-123 us-central1"
    exit 1
fi

PROJECT_ID=$1
REGION=${2:-us-central1}
SERVICE_NAME="flux-creator-api"
IMAGE_NAME="flux-creator-backend"
IMAGE_TAG="latest"
IMAGE_URL="gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG"

print_info "开始部署到 Google Cloud Run"
print_info "项目 ID: $PROJECT_ID"
print_info "区域: $REGION"
print_info "服务名称: $SERVICE_NAME"

# 检查是否安装了 gcloud
if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI 未安装，请先安装 Google Cloud SDK"
    print_info "安装指南: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# 检查是否安装了 docker
if ! command -v docker &> /dev/null; then
    print_error "Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查是否已登录
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    print_warning "未检测到活跃的 gcloud 认证"
    print_info "正在启动登录流程..."
    gcloud auth login
fi

# 设置项目
print_info "设置项目: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# 启用必要的 API
print_info "启用必要的 Google Cloud API..."
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# 配置 Docker 认证
print_info "配置 Docker 认证..."
gcloud auth configure-docker --quiet

# 检查 backend 目录是否存在
if [ ! -d "backend" ]; then
    print_error "backend 目录不存在，请确保在项目根目录运行此脚本"
    exit 1
fi

# 构建 Docker 镜像
print_info "构建 Docker 镜像: $IMAGE_URL"
docker build -t $IMAGE_URL ./backend

if [ $? -ne 0 ]; then
    print_error "Docker 镜像构建失败"
    exit 1
fi

print_success "Docker 镜像构建完成"

# 推送镜像到 Google Container Registry
print_info "推送镜像到 Google Container Registry..."
docker push $IMAGE_URL

if [ $? -ne 0 ]; then
    print_error "镜像推送失败"
    exit 1
fi

print_success "镜像推送完成"

# 部署到 Cloud Run
print_info "部署到 Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_URL \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8000 \
  --memory 2Gi \
  --cpu 1 \
  --max-instances 10 \
  --timeout 300 \
  --set-env-vars PYTHONPATH=/app,FLUX_OUTPUT_DIR=/tmp/outputs \
  --quiet

if [ $? -ne 0 ]; then
    print_error "Cloud Run 部署失败"
    exit 1
fi

# 获取服务 URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format 'value(status.url)')

print_success "部署完成！"
echo ""
print_info "=== 部署信息 ==="
print_info "服务名称: $SERVICE_NAME"
print_info "项目 ID: $PROJECT_ID"
print_info "区域: $REGION"
print_info "服务 URL: $SERVICE_URL"
echo ""
print_info "=== 下一步操作 ==="
print_info "1. 测试 API: curl $SERVICE_URL/health"
print_info "2. 查看 API 文档: $SERVICE_URL/docs"
print_info "3. 构建前端应用: ./build-cloud.sh $SERVICE_URL"
echo ""
print_info "=== 管理命令 ==="
print_info "查看日志: gcloud logs read --service $SERVICE_NAME --region $REGION"
print_info "查看服务: gcloud run services describe $SERVICE_NAME --region $REGION"
print_info "删除服务: gcloud run services delete $SERVICE_NAME --region $REGION"
echo ""

# 测试服务健康状态
print_info "测试服务健康状态..."
sleep 5
if curl -s "$SERVICE_URL/health" > /dev/null; then
    print_success "服务健康检查通过！"
else
    print_warning "服务健康检查失败，请检查日志"
    print_info "查看日志: gcloud logs read --service $SERVICE_NAME --region $REGION --limit 50"
fi

print_success "Google Cloud Run 部署脚本执行完成！"