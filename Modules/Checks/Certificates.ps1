function Check-Certificates {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "My", "LocalMachine"
    $store.Open("ReadOnly")

    $now = Get-Date
    $certs = $store.Certificates

    $xmlContent = "<Metrics><Hostname>$($hostName)</Hostname><Timestamp>$($timestamp)</Timestamp><Certificates>"

    foreach ($cert in $certs) {

        $template = $null
        $certExtensions = $cert.Extensions

        foreach ($certExtension in $certExtensions) {
                if ($certExtension.Oid.Value -eq "1.3.6.1.4.1.311.21.7") # Certificate Template Information
                {
                    $template = $certExtension.Format(0) -replace '^Template=', '' -replace '\(1.3.6.1.4.1.*', ''
                }
        }

        $dnsNameList = $cert.DnsNameList
        $issuer = $cert.Issuer
        $notBefore = $cert.NotBefore
        $notAfter = $cert.NotAfter
        $hasPrivateKey = $cert.HasPrivateKey
        $serialNumber = $cert.SerialNumber
        $subject = $cert.Subject
        $thumbprint = $cert.Thumbprint
        $version = $cert.Version

        $xmlContent += @"
<Certificate>
    <DnsNameList>$dnsNameList</DnsNameList>
    <Issuer>$issuer</Issuer>
    <NotBefore>$($notBefore.ToString("yyyy-MM-dd HH:mm:ss"))</NotBefore>
    <NotAfter>$($notAfter.ToString("yyyy-MM-dd HH:mm:ss"))</NotAfter>
    <HasPrivateKey>$hasPrivateKey</HasPrivateKey>
    <SerialNumber>$serialNumber</SerialNumber>
    <Subject>$subject</Subject>
    <Thumbprint>$thumbprint</Thumbprint>
    $(if ($template -eq $null) { '' } else { "<Template>$template</Template>" })
    <Version>$version</Version>
</Certificate>
"@
    }

    $xmlContent += "</Certificates></Metrics>"

    $store.Close()

    $xml = [xml]$xmlContent

    if ($certs.Count -ne 0)
    {
        Check-Log -Component "Certificates" -XmlData $xml
    }
}
