# sessions 定期清理脚本
# 运行: 每周日 23:00（cron）
# 逻辑: 归档 >500KB 或 >7 天的 trajectory 文件到 sessions_old/

$sessionsDir = "$env:USERPROFILE\.openclaw\agents\main\sessions"
$oldDir      = "$env:USERPROFILE\.openclaw\agents\main\sessions_old"
$cutoff      = (Get-Date).AddDays(-7)
$countMoved  = 0
$sizeTotal   = 0

# 确保 old 目录存在
if (-not (Test-Path $oldDir)) { New-Item -ItemType Directory -Path $oldDir -Force | Out-Null }

Get-ChildItem -Path $sessionsDir -Filter "*trajectory.jsonl" | ForEach-Object {
    $shouldMove = $false
    if ($_.Length -gt 500KB) {
        $shouldMove = $true
    } elseif ($_.LastWriteTime -lt $cutoff) {
        $shouldMove = $true
    }

    if ($shouldMove) {
        $sizeMB = [math]::Round($_.Length/1MB, 2)
        Write-Host "  → 归档: $($_.Name) ($sizeMB MB, $($_.LastWriteTime))"
        Move-Item -Path $_.FullName -Destination "$oldDir\$($_.Name)" -Force
        # 同时移走对应的 .path.json
        $pathFile = $_.FullName -replace '\.trajectory\.jsonl$', '.trajectory-path.json'
        if (Test-Path $pathFile) {
            Move-Item -Path $pathFile -Destination "$oldDir\$($_.Name -replace '\.trajectory\.jsonl$', '.trajectory-path.json')" -Force
        }
        $countMoved++
        $sizeTotal += [math]::Round($_.Length/1MB, 2)
    }
}

Write-Host "== 清理完成: 移动 $countMoved 个文件, 共 ~$sizeTotal MB =="
