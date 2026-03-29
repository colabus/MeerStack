function Check-Processes {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $xml = New-Object System.Xml.XmlDocument
    $root = $xml.CreateElement("Metrics")
    $xml.AppendChild($root) | Out-Null

    $hostnameElement = $xml.CreateElement("Hostname")
    $hostnameElement.InnerText = $hostname
    $root.AppendChild($hostnameElement) | Out-Null

    $timestampElement = $xml.CreateElement("Timestamp")
    $timestampElement.InnerText = $timestamp
    $root.AppendChild($timestampElement) | Out-Null

    # Processes
    $processesNode = $xml.CreateElement("Processes")
    $processesNode.SetAttribute("version", "2.0")

    $processList = Get-CimInstance Win32_Process

    $shaCache = @{}
    $processList |
        Where-Object { $_.ExecutablePath -and (Test-Path $_.ExecutablePath) } |
        Select-Object -ExpandProperty ExecutablePath -Unique |
        ForEach-Object {
            try {
                $shaCache[$_] = (Get-FileHash -Algorithm SHA256 -Path $_ -ErrorAction Stop).Hash
            } catch {
                $shaCache[$_] = $null
            }
        }

    foreach ($process in $processList) {
        try {
            $procNode = $xml.CreateElement("Process")

            $sha256 = if ($process.ExecutablePath -and $shaCache.ContainsKey($process.ExecutablePath)) {
                $shaCache[$process.ExecutablePath]
            } else {
                $null
            }

            $properties = @{
                Name         = $process.Name
                PID          = $process.ProcessId
                ParentPid    = $process.ParentProcessId
                Path         = $process.ExecutablePath
                CommandLine  = $process.CommandLine
                StartTime    = $process.CreationDate
                SessionId    = $process.SessionId
                SHA256       = $sha256
            }

            foreach ($pair in $properties.GetEnumerator()) {
                $node = $xml.CreateElement($pair.Key)
                $node.InnerText = $pair.Value
                $procNode.AppendChild($node) | Out-Null
            }

            $processesNode.AppendChild($procNode) | Out-Null
        }
        catch {
            continue
        }
    }

    $root.AppendChild($processesNode) | Out-Null

    Check-Log -Component "Processes" -XmlData $xml
}
