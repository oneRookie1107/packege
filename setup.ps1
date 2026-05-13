# ============================================
# 测试工程师环境自动安装脚本（v3.1.0）
# 使用 Chocolatey 包管理器
# 优先从 GitHub 下载安装包
# 非系统工具安装到 D:\tool 目录
# ============================================

# 安装目录配置
$SYSTEM_DRIVE = "C:"                          # 系统级工具安装位置
$TOOLS_DRIVE = "D:"                           # 应用级工具安装位置
$TOOLS_DIR = "$TOOLS_DRIVE\tool"             # 工具根目录
$AI_TOOLS_DIR = "$TOOLS_DIR\ai-tools"       # AI工具目录
$IDE_DIR = "$TOOLS_DIR\ide"                  # IDE目录
$EFFICIENCY_DIR = "$TOOLS_DIR\efficiency"    # 效率工具目录
$TEST_TOOLS_DIR = "$TOOLS_DIR\test-tools"   # 测试工具目录

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
            Write-Host "  ✓ 创建目录: $dir" -ForegroundColor Green
        }
    }
}

# 检查网络连接
function Test-NetworkConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        return $true
    } catch {
        Write-Host "⚠ 无法连接到 GitHub，将使用本地/备用源安装" -ForegroundColor Yellow
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

# 定义软件包映射
# installType: system = 系统级(C盘), app = 应用级(D:\tool)
$packageMappings = @{
    # ========== 系统级工具（安装到C盘） ==========
    'git' = @{ 
        installType = 'system'
        githubPath = "/packages/git/Git-2.42.0-64-bit.exe"
        chocoName = 'git'
        installerType = 'exe'
        silentArgs = '/VERYSILENT /NORESTART /NOCANCEL'
    }
    'python' = @{ 
        installType = 'system'
        githubPath = "/packages/python/python-3.11.6-amd64.exe"
        chocoName = 'python'
        installerType = 'exe'
        silentArgs = '/quiet InstallAllUsers=1 PrependPath=1'
    }
    'nodejs' = @{ 
        installType = 'system'
        githubPath = "/packages/nodejs/node-v20.10.0-x64.msi"
        chocoName = 'nodejs'
        installerType = 'msi'
        silentArgs = '/quiet'
    }
    'openjdk' = @{ 
        installType = 'system'
        githubPath = "/packages/openjdk/OpenJDK11U-jdk_x64_windows_hotspot_11.0.21_9.msi"
        chocoName = 'openjdk'
        installerType = 'msi'
        silentArgs = '/quiet'
    }
    
    # ========== 应用级工具（安装到D:\tool） ==========
    # IDE
    'pycharm-community' = @{ 
        installType = 'app'
        installDir = "$IDE_DIR\PyCharm"
        githubPath = "/packages/pycharm/pycharm-community-2023.2.5.exe"
        chocoName = 'pycharm-community'
        installerType = 'exe'
        silentArgs = "/S /D=$IDE_DIR\PyCharm"
    }
    
    # AI工具
    'trae' = @{ 
        installType = 'app'
        installDir = "$AI_TOOLS_DIR\Trae"
        githubPath = "/packages/ai/Trae-Setup.exe"
        downloadUrl = "https://lf-cdn.trae.ai/obj/trae-ai-us/pkg/app/releases/stable/1.0.9047/win32/Trae-Setup-x64.exe"
        installerType = 'exe'
        silentArgs = "/S /D=$AI_TOOLS_DIR\Trae"
        description = "字节跳动AI编程IDE"
    }
    'opencode' = @{ 
        installType = 'app'
        installDir = "$AI_TOOLS_DIR\OpenCode"
        githubPath = "/packages/ai/OpenCodeSetup.exe"
        downloadUrl = "https://github.com/opencode-ai/opencode/releases/latest/download/OpenCode-win32-x64.exe"
        installerType = 'exe'
        silentArgs = "/S /D=$AI_TOOLS_DIR\OpenCode"
        description = "OpenCode AI编程工具"
    }
    'claudecode' = @{ 
        installType = 'app'
        installDir = "$AI_TOOLS_DIR\ClaudeCode"
        githubPath = "/packages/ai/claude-code-cli.exe"
        downloadUrl = "https://github.com/anthropics/claude-code/releases/latest/download/claude-code.exe"
        installerType = 'binary'
        targetPath = "$AI_TOOLS_DIR\ClaudeCode\claude-code.exe"
        addToPath = "$AI_TOOLS_DIR\ClaudeCode"
        description = "Anthropic Claude Code命令行工具"
    }
    
    # 数据库（应用级）
    'mysql' = @{ 
        installType = 'app'
        installDir = "$TOOLS_DIR\MySQL"
        githubPath = "/packages/mysql/mysql-8.2.0-winx64.msi"
        chocoName = 'mysql'
        installerType = 'msi'
        silentArgs = "/quiet INSTALLDIR=`"$TOOLS_DIR\MySQL`""
    }
    'postgresql' = @{ 
        installType = 'app'
        installDir = "$TOOLS_DIR\PostgreSQL"
        githubPath = "/packages/postgresql/postgresql-16.1-1-windows-x64.exe"
        chocoName = 'postgresql'
        installerType = 'exe'
        silentArgs = "--mode unattended --prefix `"$TOOLS_DIR\PostgreSQL`""
    }
    'mongodb' = @{ 
        installType = 'app'
        installDir = "$TOOLS_DIR\MongoDB"
        githubPath = "/packages/mongodb/mongodb-windows-x86_64-7.0.4-signed.msi"
        chocoName = 'mongodb'
        installerType = 'msi'
        silentArgs = "/quiet INSTALLLOCATION=`"$TOOLS_DIR\MongoDB`""
    }
    'redis' = @{ 
        installType = 'app'
        installDir = "$TOOLS_DIR\Redis"
        githubPath = "/packages/redis/Redis-x64-5.0.14.1.msi"
        chocoName = 'redis-64'
        installerType = 'msi'
        silentArgs = "/quiet INSTALLFOLDER=`"$TOOLS_DIR\Redis`""
    }
    
    # 数据库连接工具（应用级）
    'navicat' = @{ 
        installType = 'app'
        installDir = "$TOOLS_DIR\Navicat"
        githubPath = "/packages/navicat/navicat161_premium_cs_x64.exe"
        downloadUrl = "https://download.navicat.com/download/navicat161_premium_cs_x64.exe"
        chocoName = 'navicat-premium'
        installerType = 'exe'
        silentArgs = "/S /D=$TOOLS_DIR\Navicat"
        description = "数据库管理工具（支持MySQL、PostgreSQL、MongoDB等）"
    }
    'redis-insight' = @{ 
        installType = 'app'
        installDir = "$TOOLS_DIR\RedisInsight"
        githubPath = "/packages/redis-insight/Redis-Insight-windows-installer.exe"
        downloadUrl = "https://download.redisinsight.redis.com/latest/Redis-Insight-win-installer.exe"
        chocoName = 'redis-insight'
        installerType = 'exe'
        silentArgs = "/S /D=$TOOLS_DIR\RedisInsight"
        description = "Redis 可视化客户端工具"
    }
    
    # 测试工具（应用级）
    'postman' = @{ 
        installType = 'app'
        installDir = "$TEST_TOOLS_DIR\Postman"
        githubPath = "/packages/postman/Postman-win64-Setup.exe"
        chocoName = 'postman'
        installerType = 'exe'
        silentArgs = '-s'
    }
    'jmeter' = @{ 
        installType = 'app'
        installDir = "$TEST_TOOLS_DIR\JMeter"
        githubPath = "/packages/jmeter/apache-jmeter-5.6.3.zip"
        chocoName = 'jmeter'
        installerType = 'zip'
        extractPath = "$TEST_TOOLS_DIR\JMeter"
    }
    'selenium-chrome-driver' = @{ 
        installType = 'app'
        installDir = "$TEST_TOOLS_DIR\ChromeDriver"
        githubPath = "/packages/selenium/chromedriver-win64.zip"
        chocoName = 'selenium-chrome-driver'
        installerType = 'zip'
        extractPath = "$TEST_TOOLS_DIR\ChromeDriver"
    }
    
    # 浏览器（系统级但可自定义）
    'googlechrome' = @{ 
        installType = 'system'
        githubPath = "/packages/chrome/ChromeSetup.exe"
        chocoName = 'googlechrome'
        installerType = 'exe'
        silentArgs = '/silent /install'
    }
    
    # 终端工具（应用级）
    'tortoisegit' = @{ 
        installType = 'app'
        installDir = "$TOOLS_DIR\TortoiseGit"
        githubPath = "/packages/tortoisegit/TortoiseGit-2.15.0.0-64bit.msi"
        chocoName = 'tortoisegit'
        installerType = 'msi'
        silentArgs = "/quiet INSTALLDIR=`"$TOOLS_DIR\TortoiseGit`""
    }
    'jq' = @{ 
        installType = 'app'
        installDir = "$TOOLS_DIR\jq"
        githubPath = "/packages/jq/jq-win64.exe"
        chocoName = 'jq'
        installerType = 'binary'
        targetPath = "$TOOLS_DIR\jq\jq.exe"
        addToPath = "$TOOLS_DIR\jq"
    }
    
    # 效率工具（应用级）
    'snipaste' = @{ 
        installType = 'app'
        installDir = "$EFFICIENCY_DIR\Snipaste"
        githubPath = "/packages/snipaste/Snipaste-2.8.8-x64.zip"
        chocoName = 'snipaste'
        installerType = 'zip'
        extractPath = "$EFFICIENCY_DIR\Snipaste"
    }
    'xmind' = @{ 
        installType = 'app'
        installDir = "$EFFICIENCY_DIR\XMind"
        githubPath = "/packages/xmind/XMind-2024.exe"
        downloadUrl = "https://dl.xmind.cn/XMind-for-Windows-x64bit-24.04.10311-202405.exe"
        chocoName = 'xmind'
        installerType = 'exe'
        silentArgs = "/S /D=$EFFICIENCY_DIR\XMind"
        description = "思维导图工具"
    }
}

# 从 GitHub 下载并安装函数
function Install-FromGitHub {
    param(
        [string]$PackageName,
        [hashtable]$Config
    )
    
    $downloadUrl = "$GITHUB_RAW$($Config.githubPath)"
    $fileName = Split-Path $Config.githubPath -Leaf
    $tempPath = "$env:TEMP\$fileName"
    
    Write-Host "  📥 尝试从 GitHub 下载: $fileName" -ForegroundColor Cyan
    
    try {
        # 检查 GitHub 上是否存在该文件
        $response = Invoke-WebRequest -Uri $downloadUrl -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        
        if ($response.StatusCode -eq 200) {
            # 下载文件
            Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -ErrorAction Stop
            Write-Host "  ✓ 下载成功" -ForegroundColor Green
            
            # 根据安装类型执行安装
            switch ($Config.installerType) {
                'exe' {
                    $process = Start-Process -FilePath $tempPath -ArgumentList $Config.silentArgs -Wait -NoNewWindow -PassThru
                    if ($process.ExitCode -eq 0) {
                        Write-Host "  ✓ 安装完成" -ForegroundColor Green
                        return $true
                    }
                }
                'msi' {
                    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$tempPath`" $Config.silentArgs" -Wait -NoNewWindow -PassThru
                    if ($process.ExitCode -eq 0) {
                        Write-Host "  ✓ 安装完成" -ForegroundColor Green
                        return $true
                    }
                }
                'zip' {
                    if (-not (Test-Path $Config.extractPath)) {
                        New-Item -ItemType Directory -Path $Config.extractPath -Force | Out-Null
                    }
                    Expand-Archive -Path $tempPath -DestinationPath $Config.extractPath -Force
                    Write-Host "  ✓ 解压完成到: $($Config.extractPath)" -ForegroundColor Green
                    
                    # 添加到 PATH
                    Add-ToPath -Path $Config.extractPath
                    return $true
                }
                'binary' {
                    $targetDir = Split-Path $Config.targetPath -Parent
                    if (-not (Test-Path $targetDir)) {
                        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                    }
                    Move-Item -Path $tempPath -Destination $Config.targetPath -Force
                    Write-Host "  ✓ 已安装到: $($Config.targetPath)" -ForegroundColor Green
                    
                    # 添加到 PATH
                    if ($Config.addToPath) {
                        Add-ToPath -Path $Config.addToPath
                    }
                    return $true
                }
            }
        }
    } catch {
        Write-Host "  ⚠ GitHub 下载失败: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    return $false
}

# 添加到 PATH 函数
function Add-ToPath {
    param([string]$Path)
    
    $envPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($envPath -notlike "*$Path*") {
        [Environment]::SetEnvironmentVariable("Path", "$envPath;$Path", "User")
        Write-Host "  ✓ 已添加到用户 PATH: $Path" -ForegroundColor Green
    }
    
    # 更新当前会话
    $env:Path = "$env:Path;$Path"
}

# 使用备用 URL 下载
function Install-FromUrl {
    param(
        [string]$PackageName,
        [hashtable]$Config
    )
    
    if (-not $Config.downloadUrl) {
        return $false
    }
    
    $url = $Config.downloadUrl
    $fileName = [System.IO.Path]::GetFileName($url)
    $tempPath = "$env:TEMP\$fileName"
    
    Write-Host "  📥 从官方下载: $fileName" -ForegroundColor Cyan
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $tempPath -UseBasicParsing -ErrorAction Stop
        Write-Host "  ✓ 下载成功" -ForegroundColor Green
        
        switch ($Config.installerType) {
            'exe' {
                Start-Process -FilePath $tempPath -ArgumentList $Config.silentArgs -Wait -NoNewWindow
                Write-Host "  ✓ 安装完成" -ForegroundColor Green
                return $true
            }
            'binary' {
                $targetDir = Split-Path $Config.targetPath -Parent
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                Move-Item -Path $tempPath -Destination $Config.targetPath -Force
                Write-Host "  ✓ 已安装到: $($Config.targetPath)" -ForegroundColor Green
                if ($Config.addToPath) {
                    Add-ToPath -Path $Config.addToPath
                }
                return $true
            }
        }
    } catch {
        Write-Host "  ⚠ 官方下载失败: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    return $false
}

# 安装软件函数
function Install-Software {
    param([string]$PackageName)
    
    Write-Host "正在安装: $PackageName" -ForegroundColor Yellow
    
    $config = $packageMappings[$PackageName]
    if (-not $config) {
        Write-Host "  ✗ 未找到配置: $PackageName" -ForegroundColor Red
        return
    }
    
    # 显示安装位置
    if ($config.installType -eq 'app') {
        Write-Host "  📁 安装位置: $($config.installDir)" -ForegroundColor Gray
    } else {
        Write-Host "  📁 安装位置: 系统目录 (C:)" -ForegroundColor Gray
    }
    
    $installed = $false
    
    # 第1步：尝试从 GitHub 下载
    if ($hasNetwork) {
        $installed = Install-FromGitHub -PackageName $PackageName -Config $config
    }
    
    # 第2步：尝试从官方 URL 下载
    if (-not $installed -and $hasNetwork) {
        $installed = Install-FromUrl -PackageName $PackageName -Config $config
    }
    
    # 第3步：使用 Chocolatey 安装
    if (-not $installed) {
        $chocoName = $config.chocoName
        if ($chocoName) {
            Write-Host "  📦 使用 Chocolatey 安装: $chocoName" -ForegroundColor Cyan
            try {
                # 对于应用级工具，设置 Chocolatey 安装目录
                if ($config.installType -eq 'app' -and $config.installDir) {
                    $env:ChocolateyBinRoot = $TOOLS_DRIVE
                    $env:ChocolateyToolsLocation = $TOOLS_DIR
                }
                choco install $chocoName -y --no-progress 2>&1 | Out-Null
                Write-Host "  ✓ $PackageName 安装成功" -ForegroundColor Green
                
                # 添加到 PATH
                if ($config.installType -eq 'app' -and $config.addToPath) {
                    Add-ToPath -Path $config.addToPath
                }
            } catch {
                Write-Host "  ✗ $PackageName 安装失败: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "  ✗ $PackageName 无法安装（无可用源）" -ForegroundColor Red
        }
    }
}

# 创建快捷方式函数
function Create-Shortcut {
    param(
        [string]$TargetPath,
        [string]$ShortcutName,
        [string]$IconLocation = $null
    )
    
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = "$desktopPath\$ShortcutName.lnk"
    
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $TargetPath
    if ($IconLocation) {
        $Shortcut.IconLocation = $IconLocation
    }
    $Shortcut.Save()
    
    Write-Host "  ✓ 创建桌面快捷方式: $ShortcutName" -ForegroundColor Green
}

# ============================================
# 主程序
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "测试工程师环境自动安装脚本 (v3.1.0)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "系统工具安装位置: $SYSTEM_DRIVE" -ForegroundColor Gray
Write-Host "应用工具安装位置: $TOOLS_DIR" -ForegroundColor Gray
Write-Host "GitHub 仓库: $GITHUB_REPO" -ForegroundColor Gray
Write-Host "========================================`n" -ForegroundColor Cyan

# 初始化目录
Initialize-Directories

# 定义安装列表
$systemTools = @('git', 'python', 'nodejs', 'openjdk', 'googlechrome')
$appTools = @('pycharm-community', 'trae', 'opencode', 'claudecode', 'mysql', 'postgresql', 'mongodb', 'redis', 'navicat', 'redis-insight', 'postman', 'jmeter', 'tortoisegit', 'jq', 'snipaste', 'xmind')

# 安装系统级工具
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "安装系统级工具 (C:)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
foreach ($package in $systemTools) {
    Install-Software -PackageName $package
    Write-Host ""
}

# 安装应用级工具
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "安装应用级工具 (D:\tool)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
foreach ($package in $appTools) {
    Install-Software -PackageName $package
    Write-Host ""
}

# 安装 Python 测试库
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "安装 Python 测试库..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
pip install pytest pytest-html pytest-xdist requests selenium Appium-Python-Client robotframework
Write-Host "✓ Python 测试库安装完成" -ForegroundColor Green

# 安装 Node.js 测试工具
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "安装 Node.js 测试工具..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
npm install -g @playwright/test cypress newman
Write-Host "✓ Node.js 测试工具安装完成" -ForegroundColor Green

# 安装 Web 抓包工具
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "安装 Web 抓包工具 Whistle..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
npm install -g whistle
Write-Host "✓ Whistle 安装完成！" -ForegroundColor Green
Write-Host "  启动命令: w2 start" -ForegroundColor Gray
Write-Host "  配置页面: http://localhost:8899" -ForegroundColor Gray

# Proxifier 检测提示
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "【PC 端抓包工具 - Proxifier】" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
$proxifierPath = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*Proxifier*" }
if ($proxifierPath) {
    Write-Host "✓ 检测到 Proxifier 已安装（已授权）" -ForegroundColor Green
    Write-Host "  安装路径: $($proxifierPath.InstallLocation)" -ForegroundColor Gray
} else {
    Write-Host "⚠ 未检测到 Proxifier" -ForegroundColor Yellow
    Write-Host "  建议从原电脑迁移授权版本" -ForegroundColor Yellow
    Write-Host "  或放置到: $TOOLS_DIR\Proxifier" -ForegroundColor Cyan
}
Write-Host "========================================" -ForegroundColor Yellow

# 配置 Git
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "配置 Git..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
git config --global init.defaultBranch main
git config --global core.autocrlf true
git config --global user.name "Test Engineer"
git config --global user.email "test@example.com"
Write-Host "✓ Git 配置完成" -ForegroundColor Green

# 创建测试工作目录
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "创建工作目录..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
$workDirs = @(
    "$env:USERPROFILE\Projects",
    "$env:USERPROFILE\Projects\Automation",
    "$env:USERPROFILE\Projects\ManualTest",
    "$env:USERPROFILE\Projects\PerformanceTest"
)
foreach ($dir in $workDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✓ 创建目录: $dir" -ForegroundColor Green
    }
}

# 输出安装摘要
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "安装完成！请重启电脑以应用所有更改。" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 工具安装目录结构:" -ForegroundColor White
Write-Host "  D:\tool\" -ForegroundColor Gray
Write-Host "  ├── ai-tools\        # AI 工具 (Trae, OpenCode, ClaudeCode)" -ForegroundColor Gray
Write-Host "  ├── ide\             # IDE (PyCharm)" -ForegroundColor Gray
Write-Host "  ├── test-tools\      # 测试工具 (Postman, JMeter, ChromeDriver)" -ForegroundColor Gray
Write-Host "  ├── efficiency\      # 效率工具 (Snipaste, XMind)" -ForegroundColor Gray
Write-Host "  ├── db-tools\        # 数据库连接工具 (Navicat, RedisInsight)" -ForegroundColor Gray
Write-Host "  ├── MySQL, PostgreSQL, MongoDB, Redis" -ForegroundColor Gray
Write-Host "  ├── jq, TortoiseGit" -ForegroundColor Gray
Write-Host "  └── ..." -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 常用命令:" -ForegroundColor White
Write-Host "  • w2 start           - 启动 Whistle" -ForegroundColor Gray
Write-Host "  • python --version   - 检查 Python" -ForegroundColor Gray
Write-Host "  • node --version     - 检查 Node.js" -ForegroundColor Gray
Write-Host "  • git --version      - 检查 Git" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠ 提示: AI工具需要手动确认安装完成，部分工具可能需要登录激活" -ForegroundColor Yellow
Write-Host "⚠ 提示: Navicat 为付费软件，需要购买授权" -ForegroundColor Yellow
