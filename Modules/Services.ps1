function Check-Services {
    param ($config)

    $hostName = [System.Net.Dns]::GetHostName()
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $services = $config.Checks.Services.ServicesToCheck

    # Build an XML document
    $xmlContent = "<Metrics><Hostname>$($hostName)</Hostname><Timestamp>$($timestamp)</Timestamp><Services>`n"

    foreach ($svc in $services) {
        $serviceObj = Get-Service -Name $svc -ErrorAction SilentlyContinue

        if ($null -ne $serviceObj) {
            $xmlContent += @"
<Service>
    <Name>$($serviceObj.Name)</Name>
    <DisplayName>$($serviceObj.DisplayName)</DisplayName>
    <Status>$($serviceObj.Status)</Status>
    <StartType>$($serviceObj.StartType)</StartType>
</Service>
"@
        } else {
            $xmlContent += @"
  <Service>
    <Name>$svc</Name>
    <Error>Service not found.</Error>
  </Service>
"@
        }
    }

    $xmlContent += "</Services></Metrics>"

    # Convert string to XML object
    $xml = [xml]$xmlContent

    Check-Log -Component "Services" -XmlData $xml
}