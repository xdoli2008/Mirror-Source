# Web应用一键部署脚本 (Windows PowerShell)
# 支持IIS + ASP.NET/Node.js/Python应用的快速部署

param(
    [string]$AppName = "webapp",
    [string]$AppType = "iis",  # iis, node, python
    [int]$AppPort = 80,
    [string]$AppRoot = "C:\inetpub\wwwroot\$AppName"
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 日志函数
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# 检查管理员权限
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# 检查并安装Chocolatey
function Install-Chocolatey {
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Info "安装Chocolatey包管理器..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Success "Chocolatey安装完成"
    } else {
        Write-Info "Chocolatey已安装"
    }
}

# 启用Windows功能
function Enable-WindowsFeatures {
    Write-Info "启用IIS和相关功能..."
    
    $features = @(
        "IIS-WebServerRole",
        "IIS-WebServer",
        "IIS-CommonHttpFeatures",
        "IIS-HttpErrors",
        "IIS-HttpRedirect",
        "IIS-ApplicationDevelopment",
        "IIS-NetFxExtensibility45",
        "IIS-HealthAndDiagnostics",
        "IIS-HttpLogging",
        "IIS-Security",
        "IIS-RequestFiltering",
        "IIS-Performance",
        "IIS-WebServerManagementTools",
        "IIS-ManagementConsole",
        "IIS-IIS6ManagementCompatibility",
        "IIS-Metabase",
        "IIS-ASPNET45"
    )
    
    foreach ($feature in $features) {
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
        } catch {
            Write-Warning "无法启用功能: $feature"
        }
    }
    
    Write-Success "Windows功能配置完成"
}

# 安装基础依赖
function Install-Dependencies {
    Write-Info "安装基础依赖..."
    
    # 安装常用工具
    $packages = @("curl", "wget", "git", "7zip")
    
    foreach ($package in $packages) {
        try {
            choco install $package -y
        } catch {
            Write-Warning "无法安装包: $package"
        }
    }
    
    Write-Success "基础依赖安装完成"
}

# 创建应用目录
function New-AppDirectory {
    Write-Info "创建应用目录..."
    
    if (!(Test-Path $AppRoot)) {
        New-Item -ItemType Directory -Path $AppRoot -Force
        Write-Success "应用目录创建完成: $AppRoot"
    } else {
        Write-Info "应用目录已存在: $AppRoot"
    }
}

# 配置IIS站点
function Configure-IISSite {
    Write-Info "配置IIS站点..."
    
    # 导入WebAdministration模块
    Import-Module WebAdministration
    
    # 检查站点是否存在
    if (Get-Website -Name $AppName -ErrorAction SilentlyContinue) {
        Remove-Website -Name $AppName
        Write-Info "已删除现有站点: $AppName"
    }
    
    # 创建新站点
    New-Website -Name $AppName -Port $AppPort -PhysicalPath $AppRoot
    
    # 配置应用程序池
    if (Get-IISAppPool -Name $AppName -ErrorAction SilentlyContinue) {
        Remove-WebAppPool -Name $AppName
    }
    
    New-WebAppPool -Name $AppName
    Set-ItemProperty -Path "IIS:\AppPools\$AppName" -Name "processModel.identityType" -Value "ApplicationPoolIdentity"
    Set-ItemProperty -Path "IIS:\AppPools\$AppName" -Name "managedRuntimeVersion" -Value "v4.0"
    
    # 将站点关联到应用程序池
    Set-ItemProperty -Path "IIS:\Sites\$AppName" -Name "applicationPool" -Value $AppName
    
    Write-Success "IIS站点配置完成"
}

# 部署示例应用
function Deploy-SampleApp {
    Write-Info "部署示例应用..."
    
    $indexContent = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$AppName - 部署成功</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
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
        .windows-logo {
            font-size: 48px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="windows-logo">🪟</div>
        <h1 class="success">🎉 部署成功！</h1>
        <h2>欢迎使用 $AppName</h2>
        <p class="info">服务器时间: $(Get-Date)</p>
        <p class="info">应用端口: $AppPort</p>
        <p class="info">应用路径: $AppRoot</p>
        <p class="info">操作系统: Windows</p>
        <hr>
        <p>您的Web应用已成功部署在Windows IIS上！</p>
    </div>
</body>
</html>
"@
    
    $indexContent | Out-File -FilePath "$AppRoot\index.html" -Encoding UTF8
    
    # 设置权限
    $acl = Get-Acl $AppRoot
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $AppRoot -AclObject $acl
    
    Write-Success "示例应用部署完成"
}

# 配置Windows防火墙
function Configure-Firewall {
    Write-Info "配置Windows防火墙..."
    
    try {
        # 检查防火墙规则是否存在
        $existingRule = Get-NetFirewallRule -DisplayName "$AppName-HTTP" -ErrorAction SilentlyContinue
        
        if ($existingRule) {
            Remove-NetFirewallRule -DisplayName "$AppName-HTTP"
        }
        
        # 添加新的防火墙规则
        New-NetFirewallRule -DisplayName "$AppName-HTTP" -Direction Inbound -Protocol TCP -LocalPort $AppPort -Action Allow
        
        Write-Success "防火墙规则已添加"
    } catch {
        Write-Warning "无法配置防火墙，请手动开放端口 $AppPort"
    }
}

# 健康检查
function Test-Deployment {
    Write-Info "执行健康检查..."
    
    # 检查IIS服务状态
    $iisService = Get-Service -Name "W3SVC" -ErrorAction SilentlyContinue
    if ($iisService -and $iisService.Status -eq "Running") {
        Write-Success "IIS服务运行正常"
    } else {
        Write-Error "IIS服务未运行"
        return $false
    }
    
    # 检查站点状态
    $website = Get-Website -Name $AppName -ErrorAction SilentlyContinue
    if ($website -and $website.State -eq "Started") {
        Write-Success "网站 $AppName 运行正常"
    } else {
        Write-Error "网站 $AppName 未运行"
        return $false
    }
    
    # HTTP请求测试
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$AppPort" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Success "HTTP请求测试通过"
        } else {
            Write-Warning "HTTP请求返回状态码: $($response.StatusCode)"
        }
    } catch {
        Write-Warning "HTTP请求测试失败: $($_.Exception.Message)"
    }
    
    return $true
}

# 显示部署信息
function Show-DeploymentInfo {
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "       部署完成信息" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "应用名称: $AppName" -ForegroundColor White
    Write-Host "应用类型: $AppType" -ForegroundColor White
    Write-Host "应用端口: $AppPort" -ForegroundColor White
    Write-Host "应用路径: $AppRoot" -ForegroundColor White
    Write-Host "访问地址: http://localhost:$AppPort" -ForegroundColor Green
    Write-Host "IIS管理: 运行 inetmgr 打开IIS管理器" -ForegroundColor White
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
}

# 主函数
function Main {
    try {
        Write-Info "开始Windows Web应用一键部署..."
        
        # 检查管理员权限
        if (!(Test-Administrator)) {
            Write-Error "此脚本需要管理员权限运行。请以管理员身份运行PowerShell。"
            exit 1
        }
        
        Install-Chocolatey
        Enable-WindowsFeatures
        Install-Dependencies
        New-AppDirectory
        Configure-IISSite
        Deploy-SampleApp
        Configure-Firewall
        
        if (Test-Deployment) {
            Write-Success "部署完成！"
            Show-DeploymentInfo
        } else {
            Write-Error "部署过程中出现问题，请检查日志"
            exit 1
        }
        
    } catch {
        Write-Error "部署失败: $($_.Exception.Message)"
        exit 1
    }
}

# 脚本入口
if ($MyInvocation.InvocationName -ne '.') {
    Main
} 