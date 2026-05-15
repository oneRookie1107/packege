# 测试工程师环境自动安装脚本 v3.3.0
# 简化稳定版 - 移除数据库和终端工具，新增抓包工具说明

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "测试工程师环境自动安装脚本 (v3.3.0)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 检查管理员权限
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "请以管理员身份运行此脚本！" -ForegroundColor Red
    exit
}

# 安装目录
$TOOLS_DIR = "D:\tool"
$AI_DIR = "$TOOLS_DIR\ai-tools"
$IDE_DIR = "$TOOLS_DIR\ide"
$TEST_DIR = "$TOOLS_DIR\test-tools"
$EFF_DIR = "$TOOLS_DIR\efficiency"

# 创建目录
Write-Host "`n创建工具目录..." -ForegroundColor Green
New-Item -ItemType Directory -Path $TOOLS_DIR -Force | Out-Null
New-Item -ItemType Directory -Path $AI_DIR -Force | Out-Null
New-Item -ItemType Directory -Path $IDE_DIR -Force | Out-Null
New-Item -ItemType Directory -Path $TEST_DIR -Force | Out-Null
New-Item -ItemType Directory -Path $EFF_DIR -Force | Out-Null
Write-Host "目录创建完成" -ForegroundColor Green

# 安装 Chocolatey
Write-Host "`n安装 Chocolatey..." -ForegroundColor Green
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
Write-Host "Chocolatey 安装完成" -ForegroundColor Green

# 安装系统工具 (C:)
Write-Host "`n安装系统工具 (C:)..." -ForegroundColor Green
choco install git -y --no-progress
choco install python -y --no-progress
choco install nodejs -y --no-progress
choco install openjdk -y --no-progress
choco install googlechrome -y --no-progress
Write-Host "系统工具安装完成" -ForegroundColor Green

# 安装应用工具 (D:)
Write-Host "`n安装应用工具 (D:)..." -ForegroundColor Green
choco install pycharm-community -y --no-progress --params "/InstallDir:$IDE_DIR\PyCharm"
choco install postman -y --no-progress --params "/InstallDir:$TEST_DIR\Postman"
choco install jmeter -y --no-progress --params "/InstallDir:$TEST_DIR\JMeter"
choco install snipaste -y --no-progress --params "/InstallDir:$EFF_DIR\Snipaste"
choco install xmind -y --no-progress --params "/InstallDir:$EFF_DIR\XMind"
Write-Host "应用工具安装完成" -ForegroundColor Green

# AI 工具提示
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "AI 工具需要手动下载安装：" -ForegroundColor Yellow
Write-Host "  - Claude Desktop: https://claude.ai/download" -ForegroundColor Cyan
Write-Host "  - Trae: https://trae.ai" -ForegroundColor Cyan
Write-Host "  - Cursor: https://cursor.com" -ForegroundColor Cyan
Write-Host "  建议安装到: $AI_DIR" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Yellow

# 抓包工具提示
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "抓包工具需要手动下载安装：" -ForegroundColor Yellow
Write-Host "  - Proxifier: https://www.proxifier.com/download/" -ForegroundColor Cyan
Write-Host "  建议安装到: $TEST_DIR\Proxifier" -ForegroundColor Gray
Write-Host "  注意：Proxifier 为付费软件，需要购买许可证" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Yellow

# 安装 Node 工具
Write-Host "`n安装 Node.js 工具..." -ForegroundColor Green
npm install -g @playwright/test cypress newman whistle
Write-Host "Node.js 工具安装完成" -ForegroundColor Green

# 安装 Python 库
Write-Host "`n安装 Python 测试库..." -ForegroundColor Green
pip install pytest pytest-html pytest-xdist requests selenium Appium-Python-Client robotframework
Write-Host "Python 测试库安装完成" -ForegroundColor Green

# 配置 Git
Write-Host "`n配置 Git..." -ForegroundColor Green
git config --global init.defaultBranch main
git config --global core.autocrlf true
git config --global user.name "Test Engineer"
git config --global user.email "test@example.com"
Write-Host "Git 配置完成" -ForegroundColor Green

# 创建工作目录
Write-Host "`n创建工作目录..." -ForegroundColor Green
New-Item -ItemType Directory -Path "$env:USERPROFILE\Projects\Automation" -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\Projects\ManualTest" -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\Projects\PerformanceTest" -Force | Out-Null
Write-Host "工作目录创建完成" -ForegroundColor Green

# 完成
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "安装完成！请重启电脑以应用更改。" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n安装位置:" -ForegroundColor White
Write-Host "  C:\\Program Files\\ - Git, Python, Node.js, Java, Chrome" -ForegroundColor Gray
Write-Host "  D:\\tool\\test-tool\\ - Postman, JMeter, Snipaste, XMind" -ForegroundColor Gray
Write-Host "  D:\\tool\\ai-tools\\ - AI 工具（需手动安装）" -ForegroundColor Gray
