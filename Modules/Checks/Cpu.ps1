function Check-CPU {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

    $cpu = [ordered]@{
        Hostname    = $hostname
        Timestamp   = $timestamp

        PercentProcessorTime = $cpuLoad
    }

    $json = $cpu | ConvertTo-Json -Depth 1

    Check-Log -Component "CPU" -JsonData $json
}