# Detect and configure Android SDK, Chrome, and Visual Studio for Flutter
$paths = @("${env:LOCALAPPDATA}\Android\Sdk","${env:USERPROFILE}\AppData\Local\Android\Sdk","C:\Android\sdk")
$foundSDK = $null
foreach ($p in $paths) {
    if (Test-Path $p) { $foundSDK = $p; break }
}
if ($foundSDK) {
    Write-Output "FOUND_SDK:$foundSDK"
    flutter config --android-sdk "$foundSDK"
    setx ANDROID_SDK_ROOT "$foundSDK" -m
} else {
    Write-Output "NO_SDK_FOUND"
}

$chromePaths = @("${env:ProgramFiles}\Google\Chrome\Application\chrome.exe","${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe","${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe")
$foundChrome = $null
foreach ($c in $chromePaths) {
    if (Test-Path $c) { $foundChrome = $c; break }
}
if ($foundChrome) {
    Write-Output "FOUND_CHROME:$foundChrome"
    setx CHROME_EXECUTABLE "$foundChrome" -m
} else {
    Write-Output "NO_CHROME_FOUND"
}

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (Test-Path $vswhere) {
    Write-Output "FOUND_VSWHERE"
    & $vswhere -latest -products * -property installationPath
} else {
    Write-Output "NO_VSWHERE"
}

Write-Output "Running flutter doctor -v..."
flutter doctor -v
