param($pfxString)

# Check existence of password
# Set outlocation

$pfxOutLocation = "$env:Build_SourcesDirectory\CodeSignCert.pfx"
Write-Host "PFX will be written to $pfxOutLocation"

$kvSecretBytes = [System.Convert]::FromBase64String("$pfxString")
$certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection 
$certCollection.Import($kvSecretBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
$protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, "$env:password")
[System.IO.File]::WriteAllBytes("$pfxOutLocation", $protectedCertificateBytes)

Write-Host "##vso[task.setvariable variable=pfxLocation;]$pfxOutLocation"