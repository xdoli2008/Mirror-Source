#!/bin/bash

# Web应用一键部署脚本 (Linux)
# 支持Nginx + PHP/Node.js/Python应用的快速部署

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 默认配置
APP_NAME="${APP_NAME:-webapp}"
APP_TYPE="${APP_TYPE:-nginx}"  # nginx, php, node, python
APP_PORT="${APP_PORT:-80}"
APP_ROOT="${APP_ROOT:-/var/www/${APP_NAME}}"
NGINX_CONF_PATH="/etc/nginx/sites-available/${APP_NAME}"
NGINX_ENABLED_PATH="/etc/nginx/sites-enabled/${APP_NAME}"

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        exit 1
    fi
}

# 检测操作系统
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    log_info "检测到操作系统: $OS $VER"
}

# 更新系统包
update_system() {
    log_info "更新系统包..."
    
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get upgrade -y
    elif command -v yum >/dev/null 2>&1; then
        yum update -y
    elif command -v dnf >/dev/null 2>&1; then
        dnf update -y
    else
        log_warning "无法识别包管理器，跳过系统更新"
    fi
}

# 安装基础依赖
install_dependencies() {
    log_info "安装基础依赖..."
    
    local packages="curl wget git unzip"
    
    if command -v apt-get >/dev/null 2>&1; then
        apt-get install -y $packages
    elif command -v yum >/dev/null 2>&1; then
        yum install -y $packages
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y $packages
    fi
}

# 安装Nginx
install_nginx() {
    log_info "安装Nginx..."
    
    if command -v apt-get >/dev/null 2>&1; then
        apt-get install -y nginx
    elif command -v yum >/dev/null 2>&1; then
        yum install -y nginx
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y nginx
    fi
    
    # 启动并设置开机自启
    systemctl start nginx
    systemctl enable nginx
    
    log_success "Nginx安装完成"
}

# 配置Nginx
configure_nginx() {
    log_info "配置Nginx..."
    
    # 创建应用目录
    mkdir -p "$APP_ROOT"
    
    # 生成Nginx配置文件
    cat > "$NGINX_CONF_PATH" << EOF
server {
    listen $APP_PORT;
    server_name _;
    
    root $APP_ROOT;
    index index.html index.htm index.php;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # PHP配置 (如果需要)
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }
    
    # 静态文件缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # 安全配置
    location ~ /\.ht {
        deny all;
    }
}
EOF
    
    # 启用站点
    ln -sf "$NGINX_CONF_PATH" "$NGINX_ENABLED_PATH"
    
    # 测试配置
    nginx -t
    
    # 重载Nginx
    systemctl reload nginx
    
    log_success "Nginx配置完成"
}

# 部署示例应用
deploy_sample_app() {
    log_info "部署示例应用..."
    
    cat > "$APP_ROOT/index.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$APP_NAME - 部署成功</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        .success {
            color: #28a745;
            font-size: 24px;
            margin-bottom: 20px;
        }
        .info {
            color: #6c757d;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="success">🎉 部署成功！</h1>
        <h2>欢迎使用 $APP_NAME</h2>
        <p class="info">服务器时间: $(date)</p>
        <p class="info">应用端口: $APP_PORT</p>
        <p class="info">应用路径: $APP_ROOT</p>
        <hr>
        <p>您的Web应用已成功部署并运行！</p>
    </div>
</body>
</html>
EOF
    
    # 设置权限
    chown -R www-data:www-data "$APP_ROOT"
    chmod -R 755 "$APP_ROOT"
    
    log_success "示例应用部署完成"
}

# 配置防火墙
configure_firewall() {
    log_info "配置防火墙..."
    
    if command -v ufw >/dev/null 2>&1; then
        ufw allow $APP_PORT/tcp
        log_success "UFW防火墙规则已添加"
    elif command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --permanent --add-port=$APP_PORT/tcp
        firewall-cmd --reload
        log_success "Firewalld防火墙规则已添加"
    else
        log_warning "未检测到防火墙，请手动开放端口 $APP_PORT"
    fi
}

# 健康检查
health_check() {
    log_info "执行健康检查..."
    
    # 检查Nginx状态
    if systemctl is-active --quiet nginx; then
        log_success "Nginx服务运行正常"
    else
        log_error "Nginx服务未运行"
        return 1
    fi
    
    # 检查端口监听
    if netstat -tlnp | grep -q ":$APP_PORT "; then
        log_success "端口 $APP_PORT 监听正常"
    else
        log_error "端口 $APP_PORT 未监听"
        return 1
    fi
    
    # HTTP请求测试
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$APP_PORT | grep -q "200"; then
        log_success "HTTP请求测试通过"
    else
        log_warning "HTTP请求测试失败，请检查配置"
    fi
}

# 显示部署信息
show_deployment_info() {
    echo
    echo "=================================="
    echo "       部署完成信息"
    echo "=================================="
    echo "应用名称: $APP_NAME"
    echo "应用类型: $APP_TYPE"
    echo "应用端口: $APP_PORT"
    echo "应用路径: $APP_ROOT"
    echo "访问地址: http://$(hostname -I | awk '{print $1}'):$APP_PORT"
    echo "配置文件: $NGINX_CONF_PATH"
    echo "=================================="
    echo
}

# 主函数
main() {
    log_info "开始Web应用一键部署..."
    
    check_root
    detect_os
    update_system
    install_dependencies
    install_nginx
    configure_nginx
    deploy_sample_app
    configure_firewall
    
    if health_check; then
        log_success "部署完成！"
        show_deployment_info
    else
        log_error "部署过程中出现问题，请检查日志"
        exit 1
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 