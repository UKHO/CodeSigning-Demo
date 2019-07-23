param(
    [string]
    $pfxPath
)
$signtoolPath = "C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool\signtool.exe"
& $signtoolPath sign /f $pfxPath /p $env:password /t "https://timestamp.verisign.com/scripts/timstamp.dll"