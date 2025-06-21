# Mirror-Source
开源文件镜像仓库 - 解决国内访问GitHub困难的问题

## 项目简介
本项目用于存放从GitHub下载的开源文件，包括各种工具、脚本和部署文件，方便国内用户通过Gitee等平台快速获取和使用。

## 目录结构
```
Mirror-Source/
├── README.md                    # 项目说明文档
├── tools/                       # 工具文件目录
│   ├── docker/                  # Docker相关工具
│   │   ├── docker-compose/      # docker-compose各版本
│   │   ├── dockerfiles/         # 常用Dockerfile模板
│   │   └── README.md           # Docker工具说明
│   ├── kubernetes/              # Kubernetes相关工具
│   ├── monitoring/              # 监控工具(Prometheus, Grafana等)
│   ├── databases/               # 数据库相关工具
│   └── development/             # 开发工具
├── scripts/                     # 脚本文件目录
│   ├── linux/                   # Linux专用脚本
│   │   ├── install/             # 安装脚本
│   │   ├── deploy/              # 部署脚本
│   │   └── maintenance/         # 维护脚本
│   ├── windows/                 # Windows专用脚本
│   │   ├── install/             # 安装脚本(PowerShell/Batch)
│   │   ├── deploy/              # 部署脚本
│   │   └── maintenance/         # 维护脚本
│   ├── cross-platform/          # 跨平台脚本
│   └── one-click-deploy/        # 一键部署脚本
├── configs/                     # 配置文件模板
│   ├── nginx/                   # Nginx配置模板
│   ├── apache/                  # Apache配置模板
│   ├── database/                # 数据库配置模板
│   └── monitoring/              # 监控配置模板
├── docs/                        # 文档目录
│   ├── installation/            # 安装文档
│   ├── deployment/              # 部署文档
│   └── troubleshooting/         # 故障排除文档
└── examples/                    # 使用示例
    ├── docker-compose-examples/ # Docker Compose示例
    ├── kubernetes-examples/     # Kubernetes示例
    └── script-examples/         # 脚本使用示例
```

## 使用方法

### 1. 克隆项目
```bash
# 通过Gitee克隆(推荐国内用户)
git clone https://gitee.com/your-username/Mirror-Source.git

# 通过GitHub克隆
git clone https://github.com/your-username/Mirror-Source.git
```

### 2. 使用工具
```bash
# 使用docker-compose
cd tools/docker/docker-compose/
# 选择对应版本使用

# 使用一键部署脚本
cd scripts/one-click-deploy/
./deploy-webapp.sh  # Linux
# 或
.\deploy-webapp.ps1  # Windows PowerShell
```

### 3. 使用配置模板
```bash
# 复制配置模板
cp configs/nginx/default.conf /etc/nginx/sites-available/
```

## 贡献指南
1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证
本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式
如有问题或建议，请提交 Issue 或 Pull Request。
