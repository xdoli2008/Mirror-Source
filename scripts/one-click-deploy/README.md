# 一键部署脚本

本目录包含各种常用服务的一键部署脚本，支持Linux和Windows系统。

## 脚本列表

### Web应用部署
- `deploy-nginx.sh` / `deploy-nginx.ps1` - Nginx服务器部署
- `deploy-apache.sh` / `deploy-apache.ps1` - Apache服务器部署
- `deploy-webapp.sh` / `deploy-webapp.ps1` - 通用Web应用部署

### 数据库部署
- `deploy-mysql.sh` / `deploy-mysql.ps1` - MySQL数据库部署
- `deploy-postgresql.sh` / `deploy-postgresql.ps1` - PostgreSQL数据库部署
- `deploy-redis.sh` / `deploy-redis.ps1` - Redis缓存服务部署
- `deploy-mongodb.sh` / `deploy-mongodb.ps1` - MongoDB数据库部署

### 监控系统部署
- `deploy-prometheus.sh` / `deploy-prometheus.ps1` - Prometheus监控系统
- `deploy-grafana.sh` / `deploy-grafana.ps1` - Grafana可视化面板
- `deploy-elk.sh` / `deploy-elk.ps1` - ELK日志分析栈

### 容器编排部署
- `deploy-docker-compose.sh` / `deploy-docker-compose.ps1` - Docker Compose环境
- `deploy-k8s-cluster.sh` / `deploy-k8s-cluster.ps1` - Kubernetes集群

## 使用方法

### Linux系统
```bash
# 给脚本执行权限
chmod +x deploy-webapp.sh

# 运行脚本
./deploy-webapp.sh
```

### Windows系统
```powershell
# 在PowerShell中运行
.\deploy-webapp.ps1

# 或者在CMD中运行批处理文件
deploy-webapp.bat
```

## 脚本特性

1. **自动检测系统环境** - 脚本会自动检测操作系统类型和版本
2. **依赖检查** - 自动检查并安装所需依赖
3. **配置生成** - 自动生成配置文件
4. **服务启动** - 自动启动相关服务
5. **健康检查** - 部署完成后进行服务健康检查
6. **回滚功能** - 部署失败时自动回滚

## 配置说明

每个脚本都支持通过环境变量或配置文件进行自定义配置：

```bash
# 设置环境变量
export APP_NAME="my-webapp"
export APP_PORT="8080"
export DB_PASSWORD="secure_password"

# 运行脚本
./deploy-webapp.sh
```

## 注意事项

1. 请确保有足够的系统权限运行脚本
2. 首次运行前请阅读脚本内容，了解将要执行的操作
3. 建议在测试环境先行验证
4. 重要数据请提前备份

## 故障排除

如果部署过程中遇到问题，请查看：
1. 脚本执行日志
2. 系统日志
3. 服务状态
4. 网络连接

更多故障排除信息请参考 `docs/troubleshooting/` 目录。 