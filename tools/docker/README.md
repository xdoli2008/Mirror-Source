# Docker 工具集合

本目录包含Docker相关的工具和文件。

## 目录结构

### docker-compose/
存放不同版本的docker-compose二进制文件。

#### 使用方法：
```bash
# Linux/Mac
chmod +x docker-compose-linux-x86_64
sudo mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose

# Windows
# 将docker-compose-windows-x86_64.exe重命名为docker-compose.exe
# 并添加到系统PATH环境变量中
```

#### 版本说明：
- `docker-compose-linux-x86_64` - Linux 64位版本
- `docker-compose-linux-aarch64` - Linux ARM64版本  
- `docker-compose-darwin-x86_64` - macOS Intel版本
- `docker-compose-darwin-aarch64` - macOS Apple Silicon版本
- `docker-compose-windows-x86_64.exe` - Windows 64位版本

### dockerfiles/
存放常用的Dockerfile模板。

#### 包含的模板：
- `Dockerfile.nginx` - Nginx服务器
- `Dockerfile.node` - Node.js应用
- `Dockerfile.python` - Python应用
- `Dockerfile.java` - Java应用
- `Dockerfile.golang` - Go应用

## 下载说明

所有文件均从官方GitHub仓库下载：
- Docker Compose: https://github.com/docker/compose/releases
- 其他Docker相关工具的官方仓库

## 更新日志

请查看各个子目录的README文件获取具体版本信息和更新日志。 