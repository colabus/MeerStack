function Check-Certificates {
    param (
        [hashtable]$config
    )

    $hostName  = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
 
    $xml  = New-Object System.Xml.XmlDocument
    $root = $xml.CreateElement("Metrics")
    $xml.AppendChild($root) | Out-Null
 
    $hostnameElement = $xml.CreateElement("Hostname")
    $hostnameElement.InnerText = $hostName
    $root.AppendChild($hostnameElement) | Out-Null
 
    $timestampElement = $xml.CreateElement("Timestamp")
    $timestampElement.InnerText = $timestamp
    $root.AppendChild($timestampElement) | Out-Null
 
    # Certificates
    $certificatesNode = $xml.CreateElement("Certificates")
    $certificatesNode.SetAttribute("version", "2.0")

    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "My", "LocalMachine"
    $store.Open("ReadOnly")
    $certs = $store.Certificates
 
    foreach ($cert in $certs) {
        $template = $null
        foreach ($certExtension in $cert.Extensions) {
            if ($certExtension.Oid.Value -eq "1.3.6.1.4.1.311.21.7")  # Certificate Template Information
            {
                $template = $certExtension.Format(0) -replace '^Template=', '' -replace '\(1.3.6.1.4.1.311.21.*', ''
            }
        }
 
        $certNode = $xml.CreateElement("Certificate")
 
        $certificate = @{
            DnsNameList     = $cert.DnsNameList
            Issuer          = $cert.Issuer
            NotBefore       = $cert.NotBefore.ToString("yyyy-MM-dd HH:mm:ss")
            NotAfter        = $cert.NotAfter.ToString("yyyy-MM-dd HH:mm:ss")
            HasPrivateKey   = $cert.HasPrivateKey
            SerialNumber    = $cert.SerialNumber
            Subject         = $cert.Subject
            Thumbprint      = $cert.Thumbprint
            Template        = $template
            Version         = $cert.Version
        }
 
        foreach ($pair in $certificate.GetEnumerator()) {
            $element = $xml.CreateElement($pair.Key)
            $element.InnerText = $pair.Value
            $certNode.AppendChild($element) | Out-Null
        }
 
        $certificatesNode.AppendChild($certNode) | Out-Null
    }
 
    $store.Close()
 
    $root.AppendChild($certificatesNode) | Out-Null
 
    if ($certs.Count -ne 0) {
        Check-Log -Component "Certificates" -XmlData $xml
    }
}
