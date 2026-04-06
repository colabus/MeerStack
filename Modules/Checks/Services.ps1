function Check-Services {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $servicesMonitored = $config.Checks.Services.ServicesToCheck
 
    $serviceList = Get-CimInstance -ClassName Win32_Service | Select-Object Name, DisplayName, State, StartMode, DelayedAutoStart, StartName, PathName, ServiceType

    $services = foreach ($service in $serviceList) {
        try {
            $service = [ordered]@{
                Name                = $service.Name
                DisplayName         = $service.DisplayName
                Status              = $service.State -replace ' ',''
                StartType           = $service.StartMode -replace 'Auto', 'Automatic'
                DelayedAutoStart    = $service.DelayedAutoStart
                StartName           = $service.StartName
                PathName            = $service.PathName
                ServiceType         = $service.ServiceType
            }

            if (($servicesMonitored -split '[,;]') -contains $service.Name) {
                $service['Monitored'] = $true
            }

            $service
        }
        catch {
            continue
        }
    }
 
    $payload = [ordered]@{
        Hostname  = $hostName
        Timestamp = $timestamp
        Services = @($services)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Services" -JsonData $json
}
