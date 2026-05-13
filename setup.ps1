# ============================================
# 测试工程师环境自动安装脚本（v3.1.1 - 修复版）
# 使用 Chocolatey 包管理器
# 优先从 GitHub 下载安装包
# 非系统工具安装到 D:\tool 目录
# ============================================

# 安装目录配置
$SYSTEM_DRIVE = "C:"
$TOOLS_DRIVE = "D:"
$TOOLS_DIR = "$TOOLS_DRIVE\tool"
$AI_TOOLS_DIR = "$TOOLS_DIR\ai-tools"
$IDE_DIR = "$TOOLS_DIR\ide"
$EFFICIENCY_DIR = "$TOOLS_DIR\efficiency"
$TEST_TOOLS_DIR = "$TOOLS_DIR\test-tools"

# GitHub 仓库配置
$GITHUB_REPO = "https://github.com/oneRookie1107/packege"
$GITHUB_RAW = "https://raw.githubusercontent.com/oneRookie1107/packege/main"
$GITHUB_DOWNLOAD = "https://github.com/oneRookie1107/packege/releases/download"

# 检查是否以管理员身份运行
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "请以管理员身份运行此脚本！" -ForegroundColor Red
    exit
}

# 创建工具目录
function Initialize-Directories {
    Write-Host "正在创建工具目录..." -ForegroundColor Green
    $dirs = @($TOOLS_DIR, $AI_TOOLS_DIR, $IDE_DIR, $EFFICIENCY_DIR, $TEST_TOOLS_DIR)
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "  创建目录: $dir" -ForegroundColor Green
        }
    }
}

# 检查网络连接
function Test-NetworkConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        return $true
    } catch {
        Write-Host "无法连接到 GitHub，将使用本地/备用源安装" -ForegroundColor Yellow
        return $false
    }
}

$hasNetwork = Test-NetworkConnection

# 安装 Chocolatey（如果未安装）
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "正在安装 Chocolatey..." -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    refreshenv
}

# 安装软件函数
function Install-Software {
    param(
        [string]$Name,
        [string]$GitHubPath,
        [string]$ChocoName,
        [string]$InstallDir = "",
        [string]$Type = "exe"
    )
    
    Write-Host "正在安装: $Name" -ForegroundColor Yellow
    if ($InstallDir -ne "") {
        Write-Host "  安装位置: $InstallDir" -ForegroundColor Gray
    }
    
    # 尝试从 GitHub 下载
    $downloadSuccess = $false
    if ($hasNetwork -and $GitHubPath -ne "") {
        $downloadUrl = "$GITHUB_RAW$GitHubPath"
        $fileName = Split-Path $GitHubPath -Leaf
        $tempPath = "$env:TEMP\$fileName"
        
        Write-Host "  尝试从 GitHub 下载..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
            Write-Host "  下载成功" -ForegroundColor Green
            
            if ($Type -eq "exe") {
                Start-Process -FilePath $tempPath -ArgumentList "/S" -Wait -NoNewWindow
                $downloadSuccess = $true
            } elseif ($Type -eq "msi") {
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$tempPath`" /quiet" -Wait -NoNewWindow
                $downloadSuccess = $true
            } elseif ($Type -eq "zip") {
                if (-not (Test-Path $InstallDir)) {
                    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
                }
                Expand-Archive -Path $tempPath -DestinationPath $InstallDir -Force
                Add-ToPath -Path $InstallDir
                $downloadSuccess = $true
            }
            
            if ($downloadSuccess) {
                Write-Host "  安装完成" -ForegroundColor Green
                Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                return
            }
        } catch {
            Write-Host "  GitHub 下载失败，使用 Chocolatey..." -ForegroundColor Yellow
        }
    }
    
    # 使用 Chocolatey 安装
    if ($ChocoName -ne "") {
        try {
            choco install $ChocoName -y --no-progress 2>&1 | Out-Null
            Write-Host "  Chocolatey 安装完成" -ForegroundColor Green
        } catch {
            Write-Host "  安装失败: $_" -ForegroundColor Red
        }
    }
}

# 添加到 PATH
function Add-ToPath {
    param([string]$Path)
    
    $envPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($envPath -notlike "*$Path*") {
        [Environment]::SetEnvironmentVariable("Path", "$envPath;$Path", "User")
        Write-Host "  已添加到 PATH: $Path" -ForegroundColor Green
    }
    $env:Path = "$env:Path;$Path"
}

# ============================================
# 主程序开始
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "测试工程师环境自动安装脚本 (v3.1.1)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "系统工具: C:" -ForegroundColor Gray
Write-Host "应用工具: D:\tool" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan

# 创建目录
Initialize-Directories

# 安装系统级工具 (C:)
Write-Host "`n安装系统级工具 (C:)..." -ForegroundColor Green
Install-Software -Name "Git" -GitHubPath "/packages/git/Git-2.42.0-64-bit.exe" -ChocoName "git"
Install-Software -Name "Python" -GitHubPath "/packages/python/python-3.11.6-amd64.exe" -ChocoName "python"
Install-Software -Name "Node.js" -GitHubPath "/packages/nodejs/node-v20.10.0-x64.msi" -ChocoName "nodejs" -Type "msi"
Install-Software -Name "OpenJDK" -GitHubPath "/packages/openjdk/OpenJDK11U-jdk_x64_windows_hotspot_11.0.21_9.msi" -ChocoName "openjdk" -Type "msi"
Install-Software -Name "Chrome" -GitHubPath "/packages/chrome/ChromeSetup.exe" -ChocoName "googlechrome"

# 安装应用级工具 (D:\tool)
Write-Host "`n安装应用级工具 (D:\tool)..." -ForegroundColor Green

# IDE
Install-Software -Name "PyCharm" -GitHubPath "/packages/pycharm/pycharm-community-2023.2.5.exe" -ChocoName "pycharm-community" -InstallDir "$IDE_DIR\PyCharm"

# AI工具
Install-Software -Name "Trae" -GitHubPath "/packages/ai/Trae-Setup.exe" -ChocoName "" -InstallDir "$AI_TOOLS_DIR\Trae"
Install-Software -Name "OpenCode" -GitHubPath "/packages/ai/OpenCodeSetup.exe" -ChocoName "" -InstallDir "$AI_TOOLS_DIR\OpenCode"
Install-Software -Name "ClaudeCode" -GitHubPath "/packages/ai/claude-code-cli.exe" -ChocoName "" -InstallDir "$AI_TOOLS_DIR\ClaudeCode"

# 数据库
Install-Software -Name "MySQL" -GitHubPath "/packages/mysql/mysql-8.2.0-winx64.msi" -ChocoName "mysql" -Type "msi" -InstallDir "$TOOLS_DIR\MySQL"
Install-Software -Name "PostgreSQL" -GitHubPath "/packages/postgresql/postgresql-16.1-1-windows-x64.exe" -ChocoName "postgresql" -InstallDir "$TOOLS_DIR\PostgreSQL"
Install-Software -Name "MongoDB" -GitHubPath "/packages/mongodb/mongodb-windows-x86_64-7.0.4-signed.msi" -ChocoName "mongodb" -Type "msi" -InstallDir "$TOOLS_DIR\MongoDB"
Install-Software -Name "Redis" -GitHubPath "/packages/redis/Redis-x64-5.0.14.1.msi" -ChocoName "redis-64" -Type "msi" -InstallDir "$TOOLS_DIR\Redis"

# 数据库连接工具
Install-Software -Name "Navicat" -GitHubPath "/packages/navicat/navicat161_premium_cs_x64.exe" -ChocoName "navicat-premium" -InstallDir "$TOOLS_DIR\Navicat"
Install-Software -Name "RedisInsight" -GitHubPath "/packages/redis-insight/Redis-Insight-windows-installer.exe" -ChocoName "redis-insight" -InstallDir "$TOOLS_DIR\RedisInsight"

# 测试工具
Install-Software -Name "Postman" -GitHubPath "/packages/postman/Postman-win64-Setup.exe" -ChocoName "postman" -InstallDir "$TEST_TOOLS_DIR\Postman"
Install-Software -Name "JMeter" -GitHubPath "/packages/jmeter/apache-jmeter-5.6.3.zip" -ChocoName "jmeter" -Type "zip" -InstallDir "$TEST_TOOLS_DIR\JMeter"

# 终端工具
Install-Software -Name "TortoiseGit" -GitHubPath "/packages/tortoisegit/TortoiseGit-2.15.0.0-64bit.msi" -ChocoName "tortoisegit" -Type "msi" -InstallDir "$TOOLS_DIR\TortoiseGit"

# 效率工具
Install-Software -Name "Snipaste" -GitHubPath "/packages/snipaste/Snipaste-2.8.8-x64.zip" -ChocoName "snipaste" -Type "zip" -InstallDir "$EFFICIENCY_DIR\Snipaste"
Install-Software -Name "XMind" -GitHubPath "/packages/xmind/XMind-2024.exe" -ChocoName "xmind" -InstallDir "$EFFICIENCY_DIR\XMind"

# 安装 Python 测试库
Write-Host "`n安装 Python 测试库..." -ForegroundColor Green
pip install pytest pytest-html pytest-xdist requests selenium Appium-Python-Client robotframework
Write-Host "Python 测试库安装完成" -ForegroundColor Green

# 安装 Node.js 测试工具
Write-Host "`n安装 Node.js 测试工具..." -ForegroundColor Green
npm install -g @playwright/test cypress newman
Write-Host "Node.js 测试工具安装完成" -ForegroundColor Green

# 安装 Whistle
Write-Host "`n安装 Whistle..." -ForegroundColor Green
npm install -g whistle
Write-Host "Whistle 安装完成" -ForegroundColor Green

# 配置 Git
Write-Host "`n配置 Git..." -ForegroundColor Green
git config --global init.defaultBranch main
git config --global core.autocrlf true
git config --global user.name "Test Engineer"
git config --global user.email "test@example.com"
Write-Host "Git 配置完成" -ForegroundColor Green

# 创建工作目录
Write-Host "`n创建工作目录..." -ForegroundColor Green
$workDirs = @(
    "$env:USERPROFILE\Projects",
    "$env:USERPROFILE\Projects\Automation",
    "$env:USERPROFILE\Projects\ManualTest",
    "$env:USERPROFILE\Projects\PerformanceTest"
)
foreach ($dir in $workDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "创建目录: $dir" -ForegroundColor Green
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "安装完成！请重启电脑以应用所有更改。" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n工具安装位置:" -ForegroundColor White
Write-Host "  D:\tool\ai-tools     - AI工具 (Trae, OpenCode)" -ForegroundColor Gray
Write-Host "  D:\tool\ide          - IDE (PyCharm)" -ForegroundColor Gray
Write-Host "  D:\tool\test-tools   - 测试工具 (Postman, JMeter)" -ForegroundColor Gray
Write-Host "  D:\tool\efficiency   - 效率工具 (Snipaste, XMind)" -ForegroundColor Gray
Write-Host "  D:\tool\MySQL, PostgreSQL, MongoDB, Redis" -ForegroundColor Gray
Write-Host "  D:\tool\Navicat, RedisInsight" -ForegroundColor Gray
