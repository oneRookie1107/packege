---
name: "qa-engineer-setup"
description: "测试工程师 Windows 新电脑环境一键安装脚本。批量安装 Git/Python/Node.js/OpenJDK/Chrome 等系统工具，PyCharm/微信开发者工具/Postman/JMeter/Snipaste/XMind/Obsidian/Proxifier 等应用，以及 Playwright/Cypress/pytest/selenium 等测试依赖。当用户需要为新电脑配置测试工程师工作环境、批量安装测试工具、初始化开发环境时调用。"
---

# QA Engineer Setup / 测试工程师环境一键安装

测试工程师 Windows 新电脑环境批量安装脚本（v3.5.0），通过 Chocolatey 包管理器自动安装系统工具、IDE、测试工具、效率工具及测试依赖包。

## 适用场景

当用户需要：
- 给测试工程师新电脑配置完整工作环境
- 批量安装测试相关软件和依赖
- 初始化 Python/Node.js 测试框架依赖
- 配置 D:\tool 标准化目录结构

## 安装内容

### 系统工具（C 盘）
通过 Chocolatey 安装到系统默认位置：
- **Git** 2.42.0 — 版本控制
- **Python** 3.11.6 — 编程语言
- **Node.js** 20.10.0 — JS 运行时
- **OpenJDK** 11.0.21 — Java 环境
- **Chrome** — 浏览器

### 应用工具（D:\tool）
| 类别 | 软件 | 安装路径 |
|------|------|----------|
| IDE | PyCharm Community 2023.2.5 | `D:\tool\ide\PyCharm` |
| IDE | 微信开发者工具（小程序/小游戏） | `D:\tool\ide\WeChatDevTools` |
| 测试 | Postman, JMeter 5.6.3, ChromeDriver | `D:\tool\test-tools\` |
| 效率 | Snipaste 2.8.8, XMind 2024, Obsidian | `D:\tool\efficiency\` |
| 网络 | Proxifier 4.05（付费） | `D:\tool\test-tool\Proxifier` |

### AI 工具（手动安装）
脚本仅提供下载链接，需用户手动确认安装：
- Claude Desktop — `https://claude.ai/download`
- Trae — `https://trae.ai`
- Cursor — `https://cursor.com`

### 微信开发者工具备用下载
若 Chocolatey 安装失败，可手动从官方下载：
- 官方下载页：`https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html`
- x64 直链：`https://servicewechat.com/wxa-dev-logic/download_redirect?type=x64&from=mpwiki`

### 测试依赖包
- **npm 全局**：`@playwright/test`、`cypress`、`newman`、`whistle`
- **pip**：`pytest`、`pytest-html`、`pytest-xdist`、`requests`、`selenium`、`Appium-Python-Client`、`robotframework`

## 运行方式

**前置要求**：管理员权限、网络畅通、≥20GB 可用空间。

```powershell
# 在 PowerShell 管理员窗口执行
Set-ExecutionPolicy Bypass -Scope Process -Force
& "<skill 目录>\setup.ps1"
```

## 调用流程

1. **确认环境** — 检查是否为 Windows、是否管理员权限、磁盘空间是否充足
2. **运行 setup.ps1** — 自动创建 `D:\tool` 目录结构、安装 Chocolatey、批量装系统/应用工具
3. **手动补装** — 提示用户下载 Claude Desktop / Trae / Cursor / Proxifier，必要时手动装微信开发者工具
4. **运行 test.ps1** — 验证安装结果（执行 `python --version`、`node --version` 等）
5. **重启电脑** — 应用环境变量更改

## 注意事项

- **Proxifier 为付费软件** — 建议从原电脑迁移授权或购买正版
- **安装源优先级** — 优先从 GitHub 仓库下载安装包，未找到时回退到 Chocolatey
- **AI 工具不自动装** — Claude Desktop/Trae/Cursor 因登录态/版本管理原因需手动确认
- **微信开发者工具** — Chocolatey 上的 `wechat-devtools` 包版本可能滞后，若需要最新稳定版建议走官方下载链接
- **首次运行后必须重启** — 让 PATH 等环境变量生效
- **Git 默认配置** — 脚本会设置 `init.defaultBranch=main`、`core.autocrlf=true` 及占位 user.name/email，需后续按实际身份覆盖

## 相关文件

- `setup.ps1` — 主安装脚本
- `test.ps1` — 安装验证脚本
- `skill.json` — 完整软件清单与版本配置（含 GitHub 直链下载路径）

## 来源

仓库：`https://github.com/oneRookie1107/packege`
