function Check-CPU {
    param ($config)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

    $xml = [xml] "<Metrics><Timestamp>$($timestamp)</Timestamp><CPU><PercentProcessorTime>$([math]::Round($cpuLoad, 2))</PercentProcessorTime></CPU></Metrics>"

    Write-Log -Component "CPU" -XmlData $xml
}