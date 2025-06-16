function Check-CPU {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

    $xml = [xml] "<Metrics><Hostname>$($hostName)</Hostname><Timestamp>$($timestamp)</Timestamp><CPU><PercentProcessorTime>$([math]::Round($cpuLoad, 2))</PercentProcessorTime></CPU></Metrics>"

    Check-Log -Component "CPU" -XmlData $xml
}