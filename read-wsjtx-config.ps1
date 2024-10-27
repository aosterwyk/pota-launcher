$wsjtxAppData = "$($env:LOCALAPPDATA)\WSJT-X"
$wsjtxInstallDir = "C:\WSJT"

$configSearchString = "\Common\Mode"
$wsjtxConfigs = @() 
Get-Content "$($wsjtxAppData)\WSJT-X.ini" | ForEach-Object {
    if($_.Contains("CurrentName")) {
        $wsjtxConfigs += ($_.Split("="))[1]
    }
    if($_.Contains($configSearchString)) {
        $configNameSplit = $_.Split("\")
        $configName = [uri]::UnescapeDataString($configNameSplit[0])
        $wsjtxConfigs += $configName
    }
}


$count = 0
$wsjtxConfigs | ForEach-Object {
    Write-Host "[$($count)] $($_)"
    $count++
}   
$configNumber = Read-Host "Please enter the number of the config to use"
# TODO - validate input - number only?

Write-Host "Config selected: $($wsjtxConfigs[$configNumber])"
$wsjtxArgs = ""
if($configNumber -ne 0) { # Do not pass a config arg if using current config
    $wsjtxArgs = "-c `"$($wsjtxConfigs[$configNumber])`""
    Start-Process -FilePath "$($wsjtxInstallDir)\wsjtx\bin\wsjtx.exe" -ArgumentList $wsjtxArgs
}
else {
    Start-Process -FilePath "$($wsjtxInstallDir)\wsjtx\bin\wsjtx.exe" 
}
