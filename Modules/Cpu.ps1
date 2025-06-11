function Check-CPU {
    param ($config)

    $hostName = [System.Net.Dns]::GetHostName()
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

    $xml = [xml] "<Metrics><Hostname>$($hostName)</Hostname><Timestamp>$($timestamp)</Timestamp><CPU><PercentProcessorTime>$([math]::Round($cpuLoad, 2))</PercentProcessorTime></CPU></Metrics>"

    Write-Log -Component "CPU" -XmlData $xml
}