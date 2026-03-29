if ($debug) { Write-Host -ForegroundColor White "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [Debug] Loading Variables .." }

$m_hostName = [System.Environment]::MachineName

$m_scriptStartTime = Get-Date