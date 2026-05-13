# 测试脚本 - 极简版
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "测试脚本运行正常！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "如果看到这个消息，说明 PowerShell 脚本执行正常。" -ForegroundColor Yellow
Write-Host ""
Write-Host "目录测试:" -ForegroundColor Green

$testDir = "D:\tool-test"
if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Write-Host "  创建目录成功: $testDir" -ForegroundColor Green
} else {
    Write-Host "  目录已存在: $testDir" -ForegroundColor Gray
}

Write-Host ""
Write-Host "测试完成！可以运行正式安装脚本了。" -ForegroundColor Cyan
