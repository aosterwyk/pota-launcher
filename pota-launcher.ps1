# Time in seconds to wait before starting apps after WSJT-X
$appsWait = 20 

# Launch JTAlert? 
$launchJTAlert = $true
$JTAlertFilepath = "C:\Program Files (x86)\HamApps\JTAlert\JTAlertV2.exe"

# Launch Grid Tracker?
$launchGridTracker = $false
$gridTrackerFilepath = "C:\Program Files (x86)\GridTracker\GridTracker.exe"

# Launch HAMRS?
$launchHAMRS = $true
$HAMRSFilepath = "$($env:LOCALAPPDATA)\Programs\hamrs\HAMRS.exe"
# Default: "$($env:LOCALAPPDATA)\Programs\hamrs\HAMRS.exe"

# Launch POTA spotting page
$launchPOTAPage = $true

# WSJT-X install dir
$wsjtxInstallDir = "C:\WSJT"
# WSJT-X app data location
$wsjtxAppData = "$($env:LOCALAPPDATA)\WSJT-X"
# Default: "$($env:LOCALAPPDATA)\WSJT-X"

### Do not edit anything below this line ###

# TODO - check for updates if git is installed and internet is up

# TODO - read this location from WSJTX config "AzElDir"
$oldADIName = "$($wsjtxAppData)\wsjtx_log.adi"
if (Test-Path $oldADIName) {
    Write-Host -ForegroundColor Green "Found wsjtx_log.adi."
    $newADIName = "wsjtx_log-$(Get-Date -Format "yyyyMMdd-hhmmss").adi"
    Write-Host "Renaming existing wsjtx_log.adi to $($newADIName)"
    Rename-Item -Path $oldADIName -NewName "$($wsjtxAppData)\$($newADIName)"
}
else {
    Write-Host -ForegroundColor Yellow "Can't find wsjtx_log.adi file.`nThis is safe to ignore if you renamed it or this is your first time running WSJT-X"
}

# Read config from WSJTX settings file
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

# Launch WSJTX with selected config
Write-Host "Config selected: $($wsjtxConfigs[$configNumber])"
$wsjtxArgs = ""
if($configNumber -ne 0) { # Do not pass a config arg if using current config
    $wsjtxArgs = "-c `"$($wsjtxConfigs[$configNumber])`""
    Start-Process -FilePath "$($wsjtxInstallDir)\wsjtx\bin\wsjtx.exe" -ArgumentList $wsjtxArgs
}
else {
    Start-Process -FilePath "$($wsjtxInstallDir)\wsjtx\bin\wsjtx.exe" 
}

Write-Host "Sleeping for $($appsWait) seconds before opening other apps"
Start-Sleep $appsWait

if($launchJTAlert) {
    Write-Host "Starting JTAlert"
    Start-Process -FilePath $JTAlertFilepath -ArgumentList "/wsjtx"
}

if($launchGridTracker) {
    Write-Host "Starting Grid Tracker"
    Start-Process -FilePath $gridTrackerFilepath
}

if($launchHAMRS) {
    Write-Host "Starting HAMRS" 
    Start-Process -FilePath $HAMRSFilepath
}

if($launchPOTAPage) {
    Write-Host "Opening POTA spotting page"
    Start-Process "https://pota.app/#/"
}


# Write-Host "Good luck with the activation! 73"
