
# # The certificate is downloaded from Key Vault as a string. Convert it into a PFX, password protect it and write to disk
# $kvSecretBytes = [System.Convert]::FromBase64String('$(UKHOCodeSigningCert)')
# $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection 
# $certCollection.Import($kvSecretBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
# $protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, "$(password)")
# [System.IO.File]::WriteAllBytes("$(pfxLocation)", $protectedCertificateBytes)  

gci env:

Write-Host $env:UKHOCodeSigningCert