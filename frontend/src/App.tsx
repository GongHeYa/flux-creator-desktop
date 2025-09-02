import { useState, useEffect } from 'react';
import { Input, Button, Image, Spin, message, Progress, Slider, Select, Space, Badge } from 'antd';
import { PictureOutlined, SendOutlined, DownloadOutlined, SettingOutlined } from '@ant-design/icons';
import ApiService, { getErrorMessage } from './services/apiService';
import { checkApiHealth } from './config/api';
import Settings from './components/Settings';
import './App.css';

const { TextArea } = Input;

// 声明 Electron API 类型
declare global {
  interface Window {
    electronAPI?: {
      generateImage: (prompt: string) => Promise<any>;
      getAppVersion: () => Promise<string>;
    };
  }
}

function App() {
  const [prompt, setPrompt] = useState('');
  const [loading, setLoading] = useState(false);
  const [generatedImage, setGeneratedImage] = useState<string | null>(null);
  const [appVersion, setAppVersion] = useState('');
  const [progress, setProgress] = useState(0);
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState<'online' | 'offline' | 'checking'>('checking');
  
  // 图像生成参数
  const [imageParams, setImageParams] = useState({
    width: 1024,
    height: 1024,
    steps: 20,
    cfg: 1.0,
    seed: -1
  });
  
  // 预设尺寸选项
  const sizePresets = [
    { label: '1024×1024 (正方形)', value: '1024x1024', width: 1024, height: 1024 },
    { label: '1024×768 (横向)', value: '1024x768', width: 1024, height: 768 },
    { label: '768×1024 (竖向)', value: '768x1024', width: 768, height: 1024 }
  ];

  // 获取应用版本和检查连接状态
  useEffect(() => {
    if (window.electronAPI) {
      window.electronAPI.getAppVersion().then(version => {
        setAppVersion(version);
      });
    }
    
    // 检查 API 连接状态
    checkConnection();
    
    // 定期检查连接状态
    const interval = setInterval(checkConnection, 30000); // 每30秒检查一次
    return () => clearInterval(interval);
  }, []);
  
  // 检查 API 连接状态
  const checkConnection = async () => {
    setConnectionStatus('checking');
    try {
      const result = await checkApiHealth();
      setConnectionStatus(result.status);
    } catch (error) {
      setConnectionStatus('offline');
    }
  };

  const handleGenerate = async () => {
    if (!prompt.trim()) {
      message.warning({
        content: '💡 请先输入您想要创作的图像描述',
        duration: 3,
        style: {
          marginTop: '20vh',
        },
      });
      return;
    }
    
    if (prompt.trim().length < 5) {
      message.warning({
        content: '📝 请输入更详细的描述，这样能生成更好的图像',
        duration: 3,
        style: {
          marginTop: '20vh',
        },
      });
      return;
    }

    // 检查连接状态
    if (connectionStatus === 'offline') {
      message.error({
        content: '🔌 服务器连接异常，请检查网络连接或在设置中配置正确的服务器地址',
        duration: 5,
        style: {
          marginTop: '20vh',
        },
      });
      return;
    }

    setLoading(true);
    setProgress(0);
    setGeneratedImage(null);
    
    try {
      // 使用 ApiService 生成图像
      const result = await ApiService.generateImage({
        prompt: prompt,
        width: imageParams.width,
        height: imageParams.height,
        steps: imageParams.steps,
        cfg: imageParams.cfg,
        seed: imageParams.seed
      });
      
      if (result.status === 'pending') {
        message.success({
          content: '🎨 创作任务已启动，AI 正在为您生成独特的图像...',
          duration: 3,
          style: {
            marginTop: '20vh',
          },
        });
        
        // 使用 ApiService 轮询任务状态
        try {
          const finalResult = await ApiService.pollTaskStatus(
            result.task_id,
            (progress) => {
              setProgress(Math.round(progress * 100));
            }
          );
          
          if (finalResult.status === 'completed') {
            if (finalResult.result && finalResult.result.images && finalResult.result.images.length > 0) {
              setGeneratedImage(finalResult.result.images[0].url);
              setProgress(100);
              message.success({
                content: '✨ 创作完成！您的独特图像已生成成功',
                duration: 4,
                style: {
                  marginTop: '20vh',
                },
              });
            } else {
              message.error('图像生成完成但未找到结果');
            }
          } else if (finalResult.status === 'failed') {
            const errorMsg = finalResult.error || '图像生成失败';
            message.error({
              content: `生成失败: ${errorMsg}`,
              duration: 5,
              style: {
                marginTop: '20vh',
              },
            });
            setProgress(0);
          }
        } catch (pollError) {
          console.error('Polling error:', pollError);
          message.error({
            content: `状态查询失败: ${getErrorMessage(pollError)}`,
            duration: 5,
            style: {
              marginTop: '20vh',
            },
          });
          setProgress(0);
        }
      } else {
        const errorMsg = result.message || '提交生成任务失败';
        message.error({
          content: `任务提交失败: ${errorMsg}`,
          duration: 5,
          style: {
            marginTop: '20vh',
          },
        });
        setProgress(0);
      }
    } catch (error) {
      console.error('Generation error:', error);
      
      const errorMessage = getErrorMessage(error);
      message.error({
        content: `生成失败: ${errorMessage}`,
        duration: 8,
        style: {
          marginTop: '20vh',
        },
      });
      setProgress(0);
      
      // 重新检查连接状态
      checkConnection();
    } finally {
      setLoading(false);
    }
  };

  const handleDownload = async () => {
    if (!generatedImage) {
      message.warning({
        content: '📷 没有可下载的图像',
        duration: 3,
        style: {
          marginTop: '20vh',
        },
      });
      return;
    }
    
    try {
      message.loading({
        content: '正在准备下载...',
        duration: 0,
        key: 'download',
        style: {
          marginTop: '20vh',
        },
      });
      
      await ApiService.downloadImage(generatedImage, `flux-generated-${Date.now()}.png`);
      
      message.success({
        content: '💾 图像已成功保存到下载文件夹',
        duration: 3,
        key: 'download',
        style: {
          marginTop: '20vh',
        },
      });
    } catch (error) {
      console.error('Download error:', error);
      message.error({
        content: `下载失败: ${getErrorMessage(error)}`,
        duration: 5,
        key: 'download',
        style: {
          marginTop: '20vh',
        },
      });
    }
  };

  return (
    <div className="bear-app">
      {/* 顶部标题栏 */}
      <div className="bear-header">
        <div className="header-left">
          <PictureOutlined className="app-icon" />
          <h1 className="app-title">FLUX Creator</h1>
        </div>
        <div className="header-right">
          <Space>
            <Badge 
              status={connectionStatus === 'online' ? 'success' : connectionStatus === 'offline' ? 'error' : 'processing'}
              text={
                connectionStatus === 'online' ? '已连接' : 
                connectionStatus === 'offline' ? '离线' : '检查中'
              }
            />
            <Button 
              type="text" 
              icon={<SettingOutlined />} 
              onClick={() => setShowSettings(true)}
              title="设置"
            >
              设置
            </Button>
            <span className="version-badge">v{appVersion}</span>
          </Space>
        </div>
      </div>

      <div className="bear-container">
        {/* 左侧输入面板 */}
        <div className="input-panel">
          <div className="panel-section">
            <h3 className="section-title">创作描述</h3>
            <TextArea
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              placeholder="描述您想要创作的图像...\n\n例如：一只可爱的橙色小猫坐在窗台上，阳光透过窗户洒在它身上，背景是模糊的花园景色"
              rows={6}
              className="bear-textarea"
            />
          </div>

          {/* 参数控制面板 */}
          <div className="panel-section">
            <div className="section-header">
              <h3 className="section-title">生成参数</h3>
              <Button
                type="text"
                icon={<SettingOutlined />}
                onClick={() => setShowAdvanced(!showAdvanced)}
                className="toggle-advanced"
              >
                {showAdvanced ? '收起' : '展开'}
              </Button>
            </div>
            
            <div className="param-group">
              <label className="param-label">图像尺寸</label>
              <Select
                value={`${imageParams.width}x${imageParams.height}`}
                onChange={(value) => {
                  const preset = sizePresets.find(p => p.value === value);
                  if (preset) {
                    setImageParams(prev => ({
                      ...prev,
                      width: preset.width,
                      height: preset.height
                    }));
                  }
                }}
                className="bear-select"
              >
                {sizePresets.map(preset => (
                  <Select.Option key={preset.value} value={preset.value}>
                    {preset.label}
                  </Select.Option>
                ))}
              </Select>
            </div>

            {showAdvanced && (
              <>
                <div className="param-group">
                  <label className="param-label">生成步数: {imageParams.steps}</label>
                  <Slider
                    min={10}
                    max={50}
                    value={imageParams.steps}
                    onChange={(value) => setImageParams(prev => ({ ...prev, steps: value }))}
                    className="bear-slider"
                  />
                </div>
                
                <div className="param-group">
                  <label className="param-label">引导强度: {imageParams.cfg}</label>
                  <Slider
                    min={0.5}
                    max={2.0}
                    step={0.1}
                    value={imageParams.cfg}
                    onChange={(value) => setImageParams(prev => ({ ...prev, cfg: value }))}
                    className="bear-slider"
                  />
                </div>
                
                <div className="param-group">
                  <label className="param-label">随机种子</label>
                  <Input
                    type="number"
                    value={imageParams.seed === -1 ? '' : imageParams.seed}
                    onChange={(e) => {
                      const value = e.target.value === '' ? -1 : parseInt(e.target.value);
                      setImageParams(prev => ({ ...prev, seed: value }));
                    }}
                    placeholder="随机 (-1)"
                    className="bear-input"
                  />
                </div>
              </>
            )}
          </div>

          {/* 生成按钮 */}
          <div className="generate-section">
            {loading && progress > 0 && (
              <div className="progress-section">
                <Progress
                  percent={progress}
                  strokeColor="#FF6B35"
                  className="bear-progress"
                />
                <span className="progress-text">生成中... {progress}%</span>
              </div>
            )}
            
            <Button
              type="primary"
              icon={<SendOutlined />}
              onClick={handleGenerate}
              loading={loading}
              size="large"
              className="bear-generate-btn"
              disabled={!prompt.trim()}
            >
              {loading ? '创作中...' : '开始创作'}
            </Button>
          </div>
        </div>

        {/* 右侧结果面板 */}
        <div className="result-panel">
          <div className="panel-section">
            <h3 className="section-title">创作结果</h3>
            
            <div className="result-area">
              {loading && (
                <div className="loading-state">
                  <Spin size="large" className="bear-spin" />
                  <p className="loading-message">
                    AI 正在为您创作独特的图像...
                  </p>
                </div>
              )}
              
              {generatedImage && (
                <div className="image-result">
                  <div className="image-wrapper">
                    <Image
                      src={generatedImage}
                      alt="Generated Image"
                      className="result-image"
                      preview={{
                        mask: '点击查看大图'
                      }}
                    />
                  </div>
                  
                  <div className="image-actions">
                    <Button
                      icon={<DownloadOutlined />}
                      onClick={handleDownload}
                      className="bear-action-btn"
                    >
                      保存图像
                    </Button>
                  </div>
                </div>
              )}
              
              {!loading && !generatedImage && (
                <div className="empty-result">
                  <PictureOutlined className="empty-icon" />
                  <h4 className="empty-title">准备开始创作</h4>
                  <p className="empty-description">
                    输入您的创意描述，让 AI 为您创作独特的图像作品
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
      
      {/* Settings Modal */}
      <Settings 
        visible={showSettings} 
        onClose={() => setShowSettings(false)} 
      />
    </div>
  );
 }

export default App;
