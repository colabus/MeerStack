function Check-Services {
    param (
        [hashtable]$config
    )

    $hostName  = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $services  = $config.Checks.Services.ServicesToCheck
 
    $xml  = New-Object System.Xml.XmlDocument
    $root = $xml.CreateElement("Metrics")
    $xml.AppendChild($root) | Out-Null
 
    $hostnameElement = $xml.CreateElement("Hostname")
    $hostnameElement.InnerText = $hostName
    $root.AppendChild($hostnameElement) | Out-Null
 
    $timestampElement = $xml.CreateElement("Timestamp")
    $timestampElement.InnerText = $timestamp
    $root.AppendChild($timestampElement) | Out-Null
 
    $servicesNode = $xml.CreateElement("Services")

    $servicesObj = Get-Service | Select Name, DisplayName, Status, StartType
 
    foreach ($svc in $services) {
        $serviceObj = $servicesObj | Where-Object Name -eq $svc
 
        $serviceNode = $xml.CreateElement("Service")
 
        if ($null -ne $serviceObj) {
            $service = @{
                Name           = $serviceObj.Name
                DisplayName = $serviceObj.DisplayName
                Status      = $serviceObj.Status
                StartType   = $serviceObj.StartType
            }
        } else {
            continue
        }
 
        foreach ($pair in $service.GetEnumerator()) {
            $element = $xml.CreateElement($pair.Key)
            $element.InnerText = $pair.Value
            $serviceNode.AppendChild($element) | Out-Null
        }
 
        $servicesNode.AppendChild($serviceNode) | Out-Null
    }
 
    $root.AppendChild($servicesNode) | Out-Null
 
    if ($servicesNode.ChildNodes.Count -ne 0) {
        Check-Log -Component "Services" -XmlData $xml
    }
}
