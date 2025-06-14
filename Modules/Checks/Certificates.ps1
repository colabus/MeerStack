function Check-Certificates {
    param (
        [hashtable]$config
    )

    $hostName = [System.Net.Dns]::GetHostName()
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "My", "LocalMachine"
    $store.Open("ReadOnly")

    $now = Get-Date
    $certs = $store.Certificates

    $xmlContent = "<Metrics><Hostname>$($hostName)</Hostname><Timestamp>$($timestamp)</Timestamp><Certificates>"

    foreach ($cert in $certs) {
        $subject = $cert.Subject
        $issuer = $cert.Issuer
        $thumbprint = $cert.Thumbprint
        $hasPrivateKey = $cert.HasPrivateKey
        $dnsNameList = $cert.DnsNameList
        $notBefore = $cert.NotBefore
        $notAfter = $cert.NotAfter
        $daysRemaining = ($notAfter - $now).Days

        $xmlContent += @"
<Certificate>
    <Subject>$subject</Subject>
    <Issuer>$issuer</Issuer>
    <Thumbprint>$thumbprint</Thumbprint>
    <HasPrivateKey>$hasPrivateKey</HasPrivateKey>
    <DnsNameList>$dnsNameList</DnsNameList>
    <NotBefore>$($notBefore.ToString("yyyy-MM-dd HH:mm:ss"))</NotBefore>
    <NotAfter>$($notAfter.ToString("yyyy-MM-dd HH:mm:ss"))</NotAfter>
    <DaysRemaining>$daysRemaining</DaysRemaining>
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
