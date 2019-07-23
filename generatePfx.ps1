param
(
    $pfxString,
    $pfxPasswordVariableName = "Password" # See for details on why not passing string - https://docs.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#secret-variables
)

if(-not(Test-Path env:$pfxPasswordVariableName)){
    $errorMessage = "$pfxPasswordVariableName does not exist as an environment variable. This needs to be set and contain the intended password for PFX"
    Write-Host $errorMessage
    Write-Host "##vso[task.logissue type=error]$errorMessage"
    exit 1
}

# Check existence of password
# Set outlocation
# Set password

$pfxOutLocation = "$env:Build_SourcesDirectory\CodeSignCert.pfx"
Write-Host "PFX will be written to $pfxOutLocation"

$kvSecretBytes = [System.Convert]::FromBase64String("$pfxString")
$certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection 
$certCollection.Import($kvSecretBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
$protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, "$env:password")
[System.IO.File]::WriteAllBytes("$pfxOutLocation", $protectedCertificateBytes)

Write-Host "PFX has been created at $pfxOutLocation"
Write-Host "##vso[task.setvariable variable=pfxLocation;]$pfxOutLocation"