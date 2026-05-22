#
# OpenClaw Daily Health Check
# Checks log, sessions, config, and process health
#
param()

$ConfigPath = "C:\Users\KUHN\.openclaw\openclaw.json"
$ErrLog    = "C:\Users\KUHN\.openclaw\logs\gateway.err.log"
$Sessions  = "C:\Users\KUHN\.openclaw\agents\main\sessions"
$LogDir    = "C:\Users\KUHN\.openclaw\logs"

$CheckTime = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")
$Report = @{
    timestamp   = $CheckTime
    checks      = @{}
    alerts      = @()
    suggestions = @()
}

# -- 1. Error Log Scan --
if (Test-Path $ErrLog) {
    $recent = Get-Content $ErrLog -Tail 200

    $mrLines = $recent | Select-String "model-resolution:(\d+)ms"
    $slowMr = @()
    foreach ($m in $mrLines) {
        if ($m.Matches.Groups[1].Value -as [int] -gt 10000) {
            $slowMr += $m.Line
        }
    }
    $Report.checks["modelResolutionSlow"] = @{ count = $slowMr.Count; latest = if ($slowMr.Count -gt 0) { $slowMr[-1] } else { $null } }
    if ($slowMr.Count -gt 0) { $Report.alerts += "[WARN] model-resolution >10s ($($slowMr.Count) times)" }

    $elLines = $recent | Select-String "eventLoopDelayMaxMs=(\d+\.?\d*)"
    $slowEl = @()
    foreach ($m in $elLines) {
        if ($m.Matches.Groups[1].Value -as [double] -gt 5000) {
            $slowEl += $m.Line
        }
    }
    $Report.checks["eventLoopSlow"] = @{ count = $slowEl.Count; latest = if ($slowEl.Count -gt 0) { $slowEl[-1] } else { $null } }
    if ($slowEl.Count -gt 0) { $Report.alerts += "[WARN] Event loop delay >5s ($($slowEl.Count) times)" }

    $badKeyLines = $recent | Select-String "Unrecognized key"
    $Report.checks["configInvalidKeys"] = @{ count = $badKeyLines.Count }
    if ($badKeyLines.Count -gt 0) { $Report.alerts += "[ERR] Config has unrecognized keys" }

    $wsLines = $recent | Select-String "closed before connect"
    $Report.checks["wsDisconnects"] = @{ count = $wsLines.Count }
    if ($wsLines.Count -gt 10) { $Report.alerts += "[WARN] Frequent WS disconnects ($($wsLines.Count) times)" }

    $stuckLines = $recent | Select-String "stuck session"
    $Report.checks["stuckSessions"] = @{ count = $stuckLines.Count }
    if ($stuckLines.Count -gt 0) { $Report.alerts += "[WARN] Stuck session detected ($($stuckLines.Count) times)" }

    $failLines = $recent | Select-String "Gateway failed to start"
    if ($failLines.Count -gt 0) { $Report.alerts += "[ERR] Gateway startup failure ($($failLines.Count) times)" }
} else {
    $Report.checks["errLog"] = "not found"
    $Report.alerts += "[ERR] Error log file not found"
}

# -- 2. Session File Health --
if (Test-Path $Sessions) {
    $trajFiles = Get-ChildItem -Path $Sessions -Filter "*.trajectory.jsonl" | Sort-Object Length -Descending
    $resetFiles = Get-ChildItem -Path $Sessions -Filter "*.reset.*" | Sort-Object Length -Descending

    $largeTraj = @()
    $totalTrajSize = 0
    foreach ($f in $trajFiles) { $totalTrajSize += $f.Length; if ($f.Length -gt 500KB) { $largeTraj += $f.Name } }

    $largeReset = @()
    foreach ($f in $resetFiles) { if ($f.Length -gt 500KB) { $largeReset += $f.Name } }

    $Report.checks["sessions"] = @{
        trajectoryCount = $trajFiles.Count
        totalTrajectorySizeMB = [math]::Round($totalTrajSize / 1MB, 1)
        staleResetCount = $resetFiles.Count
        largeFiles = $largeTraj + $largeReset
    }
    if ($largeTraj.Count -gt 0) {
        $Report.alerts += "[WARN] Large trajectory: $($largeTraj.Count) files >500KB (total $([math]::Round($totalTrajSize/1MB,1))MB)"
        $Report.suggestions += "[ARCHIVE] Archive: $($largeTraj -join ', ')"
    }
    if ($largeReset.Count -gt 0) {
        $Report.alerts += "[INFO] Stale .reset: $($largeReset.Count) files >500KB"
        $Report.suggestions += "[CLEANUP] Delete stale .reset backups"
    }
} else {
    $Report.checks["sessions"] = "not found"
}

# -- 3. Config Validation --
if (Test-Path $ConfigPath) {
    try {
        $rawConfig = Get-Content $ConfigPath -Raw
        $config = $rawConfig | ConvertFrom-Json -ErrorAction Stop

        $noProxy = $config.env.vars.no_proxy
        if ($noProxy -notmatch 'deepseek') { $Report.alerts += "[ERR] no_proxy missing .deepseek.com"; $Report.suggestions += "[FIX] Add .deepseek.com to no_proxy" }

        if ($rawConfig -match 'timeoutSeconds') { $Report.alerts += "[ERR] Config has deprecated timeoutSeconds"; $Report.suggestions += "[FIX] Remove timeoutSeconds field" }
    } catch {
        $Report.alerts += "[ERR] Config parse failed: $($_.Exception.Message.Substring(0, [Math]::Min(100, $_.Exception.Message.Length)))"
        $Report.suggestions += "[FIX] Run openclaw doctor --fix"
    }
} else {
    $Report.alerts += "[ERR] Config file not found"
}

# -- 4. Gateway Process --
$nodeProcs = Get-Process -Name "node" -ErrorAction SilentlyContinue
$Report.checks["nodeProcesses"] = @{ count = $nodeProcs.Count }
if ($nodeProcs.Count -eq 0) { $Report.alerts += "[ERR] Node process not running (Gateway stopped)" }
elseif ($nodeProcs.Count -gt 2) { $Report.alerts += "[WARN] Node process count abnormal ($($nodeProcs.Count)), possible zombies"; $Report.suggestions += "[FIX] taskkill /F /IM node.exe then restart" }

# -- 5. Log Size --
$logSize = (Get-ChildItem $LogDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
$Report.checks["logDirSizeMB"] = [math]::Round($logSize / 1MB, 2)
if ($logSize -gt 100MB) { $Report.alerts += "[WARN] Log dir >100MB ($([math]::Round($logSize/1MB,1))MB)"; $Report.suggestions += "[CLEANUP] Archive old logs" }

# -- 6. Severity --
$hasErr = ($Report.alerts | Where-Object { $_ -match '\[ERR\]' }).Count -gt 0
$hasWarn = ($Report.alerts | Where-Object { $_ -match '\[WARN\]' }).Count -gt 0
if ($Report.alerts.Count -eq 0) { $severity = "GREEN" }
elseif ($hasErr) { $severity = "RED" }
elseif ($hasWarn) { $severity = "YELLOW" }
else { $severity = "GREEN" }

$trajTotalMB = [math]::Round($totalTrajSize / 1MB, 1)
$logTotalMB = [math]::Round($logSize / 1MB, 1)
$Report.summary = "Severity: $severity | Alerts: $($Report.alerts.Count) | Trajectory: ${trajTotalMB}MB | Node: $($nodeProcs.Count) | Logs: ${logTotalMB}MB"

$Report | ConvertTo-Json -Depth 4
