import React, { useState, useEffect } from 'react';
import { Modal, Input, Button, Form, message, Space, Typography, Divider, Alert } from 'antd';
import { SettingOutlined, CloudOutlined, KeyOutlined, CheckCircleOutlined, ExclamationCircleOutlined } from '@ant-design/icons';
import { getConfig, saveApiConfig, checkApiHealth } from '../config/api';

const { Text, Title } = Typography;

interface SettingsProps {
  visible: boolean;
  onClose: () => void;
}

interface ConnectionStatus {
  status: 'checking' | 'online' | 'offline';
  message: string;
}

const Settings: React.FC<SettingsProps> = ({ visible, onClose }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState<ConnectionStatus>({
    status: 'offline',
    message: '未检查'
  });

  // 加载当前配置
  useEffect(() => {
    if (visible) {
      const config = getConfig();
      form.setFieldsValue({
        baseUrl: config.baseUrl,
        apiKey: localStorage.getItem('flux-api-key') || ''
      });
      checkConnection();
    }
  }, [visible, form]);

  // 检查连接状态
  const checkConnection = async () => {
    setConnectionStatus({ status: 'checking', message: '检查中...' });
    try {
      const result = await checkApiHealth();
      setConnectionStatus({
        status: result.status,
        message: result.message
      });
    } catch (error) {
      setConnectionStatus({
        status: 'offline',
        message: '连接检查失败'
      });
    }
  };

  // 保存设置
  const handleSave = async () => {
    try {
      setLoading(true);
      const values = await form.validateFields();
      
      // 保存 API 配置
      saveApiConfig({
        baseUrl: values.baseUrl.replace(/\/$/, '') // 移除末尾斜杠
      });
      
      // 保存 API 密钥
      if (values.apiKey) {
        localStorage.setItem('flux-api-key', values.apiKey);
      } else {
        localStorage.removeItem('flux-api-key');
      }
      
      message.success('设置已保存');
      
      // 重新检查连接
      await checkConnection();
      
      onClose();
    } catch (error) {
      console.error('Save settings error:', error);
      message.error('保存设置失败');
    } finally {
      setLoading(false);
    }
  };

  // 重置为默认设置
  const handleReset = () => {
    form.setFieldsValue({
      baseUrl: 'http://localhost:8000',
      apiKey: ''
    });
  };

  // 测试连接
  const handleTestConnection = async () => {
    try {
      const values = await form.validateFields(['baseUrl']);
      
      // 临时保存配置进行测试
      const originalConfig = getConfig();
      saveApiConfig({ baseUrl: values.baseUrl.replace(/\/$/, '') });
      
      await checkConnection();
      
      // 如果测试失败，恢复原配置
      if (connectionStatus.status === 'offline') {
        saveApiConfig(originalConfig);
      }
    } catch (error) {
      message.error('请先填写正确的服务器地址');
    }
  };

  const getStatusIcon = () => {
    switch (connectionStatus.status) {
      case 'online':
        return <CheckCircleOutlined style={{ color: '#52c41a' }} />;
      case 'offline':
        return <ExclamationCircleOutlined style={{ color: '#ff4d4f' }} />;
      default:
        return <CloudOutlined style={{ color: '#1890ff' }} />;
    }
  };

  const getStatusColor = () => {
    switch (connectionStatus.status) {
      case 'online':
        return 'success';
      case 'offline':
        return 'error';
      default:
        return 'info';
    }
  };

  return (
    <Modal
      title={
        <Space>
          <SettingOutlined />
          <span>应用设置</span>
        </Space>
      }
      open={visible}
      onCancel={onClose}
      footer={[
        <Button key="reset" onClick={handleReset}>
          重置默认
        </Button>,
        <Button key="test" onClick={handleTestConnection} loading={connectionStatus.status === 'checking'}>
          测试连接
        </Button>,
        <Button key="cancel" onClick={onClose}>
          取消
        </Button>,
        <Button key="save" type="primary" onClick={handleSave} loading={loading}>
          保存设置
        </Button>
      ]}
      width={600}
      destroyOnClose
    >
      <Form
        form={form}
        layout="vertical"
        initialValues={{
          baseUrl: 'http://localhost:8000',
          apiKey: ''
        }}
      >
        <Title level={5}>
          <CloudOutlined /> 服务器配置
        </Title>
        
        <Form.Item
          label="服务器地址"
          name="baseUrl"
          rules={[
            { required: true, message: '请输入服务器地址' },
            { type: 'url', message: '请输入有效的 URL 地址' }
          ]}
          extra="FLUX 图像生成服务的完整地址，例如：https://your-server.com 或 http://localhost:8000"
        >
          <Input
            placeholder="https://your-flux-server.com"
            prefix={<CloudOutlined />}
          />
        </Form.Item>

        <Alert
          message={
            <Space>
              {getStatusIcon()}
              <Text>连接状态: {connectionStatus.message}</Text>
            </Space>
          }
          type={getStatusColor()}
          showIcon={false}
          style={{ marginBottom: 16 }}
        />

        <Divider />

        <Title level={5}>
          <KeyOutlined /> 认证配置
        </Title>
        
        <Form.Item
          label="API 密钥"
          name="apiKey"
          extra="如果服务器需要认证，请输入 API 密钥（可选）"
        >
          <Input.Password
            placeholder="输入 API 密钥（可选）"
            prefix={<KeyOutlined />}
          />
        </Form.Item>

        <Alert
          message="安全提示"
          description="API 密钥将安全存储在本地，不会上传到任何第三方服务器。"
          type="info"
          showIcon
        />
      </Form>
    </Modal>
  );
};

export default Settings;