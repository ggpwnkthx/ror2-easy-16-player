function Get-SteamApp {
    $steam_install_paths = @()
    $steam_install_paths += (Get-ItemProperty -Path HKLM:SOFTWARE\WOW6432Node\Valve\Steam).InstallPath
    $lib_path="$steam_install_paths\steamapps\libraryfolders.vdf"
    if (Test-Path -Path $lib_path) {
        $data = Get-Content -Raw -Path $steam_path$lib_path
        $steam_install_paths += ($data | Select-String -Pattern '"[0-9].*"\t\t"(.*)"' -AllMatches).Matches | foreach {$_.Groups[1].Value.Replace('\\', '\')}
    }
    $steam_apps_info = @()
    foreach ($sip in $steam_install_paths) {
        $manifest_paths = Get-ChildItem -name $sip\steamapps -Filter "appmanifest_*.acf"
        foreach ($manifest in $manifest_paths) {
            $data = Get-Content -Raw -Path $sip\steamapps\$manifest
            $app_info = New-Object PSObject -Property @{
                AppID = [int]($data | Select-String -Pattern '.*"appid"\t\t"(.*)"').Matches.Groups[1].ToString()
                Name = [string]($data | Select-String -Pattern '.*"name"\t\t"(.*)"').Matches.Groups[1].ToString()
                InstallDir = [string]($sip+"\steamapps\common\"+($data | Select-String -Pattern '.*"installdir"\t\t"(.*)"').Matches.Groups[1].ToString())
            }
            $app_info
        }
    }
}

$ror2_dir = (Get-SteamApp | Where AppID -EQ 632360).InstallDir

Write-Host "Found 'Risk of Rain 2' install directory at:"
Write-Host "    $ror2_dir"
Write-Host ""

if(!(test-path "$ror2_dir\downloads")) {
      New-Item -ItemType Directory -Force -Path "$ror2_dir\downloads" | Out-Null
}

Write-Host "Downloading 'bbepis-BepInExPack'..."
$bbepis_url="https://thunderstore.fra1.cdn.digitaloceanspaces.com/live/repository/packages/bbepis-BepInExPack-5.3.1.zip"
Invoke-WebRequest -Uri $bbepis_url -OutFile "$ror2_dir\downloads\bbepis.zip"
Write-Host "Installing 'bbepis-BepInExPack'..."
Expand-Archive -Path "$ror2_dir\downloads\bbepis.zip" -DestinationPath "$ror2_dir\downloads" -Force
Copy-Item "$ror2_dir\downloads\BepInExPack\*" "$ror2_dir" -Recurse -Force
Remove-Item -Path "$ror2_dir\downloads\*" -Recurse
Write-Host "'bbepis-BepInExPack' has been installed."
Write-Host ""

Write-Host "Downloading 'R2API'..."
$r2api_url="https://thunderstore.fra1.cdn.digitaloceanspaces.com/live/repository/packages/tristanmcpherson-R2API-2.5.14.zip"
Invoke-WebRequest -Uri $r2api_url -OutFile "$ror2_dir\downloads\r2api.zip"
Write-Host "Installing 'R2API'..."
Expand-Archive -Path "$ror2_dir\downloads\r2api.zip" -DestinationPath "$ror2_dir\downloads" -Force
Copy-Item "$ror2_dir\downloads\monomod\*" "$ror2_dir\BepInEx\monomod" -Recurse -Force
Copy-Item "$ror2_dir\downloads\plugins\*" "$ror2_dir\BepInEx\plugins" -Recurse -Force
Remove-Item -Path "$ror2_dir\downloads\*" -Recurse
Write-Host "'R2API' has been installed."
Write-Host ""

Write-Host "Downloading 'TooManyFriends'"
$toomanyfriends_url="https://thunderstore.fra1.cdn.digitaloceanspaces.com/live/repository/packages/wildbook-TooManyFriends-1.1.1.zip"
Invoke-WebRequest -Uri $toomanyfriends_url -OutFile "$ror2_dir\downloads\toomanyfriends.zip"
Write-Host "Installing 'TooManyFriends'"
Expand-Archive -Path "$ror2_dir\downloads\toomanyfriends.zip" -DestinationPath "$ror2_dir\downloads" -Force
Copy-Item "$ror2_dir\downloads\TooManyFriends.dll" "$ror2_dir\BepInEx\plugins\TooManyFriends.dll" -Force
Write-Host "'TooManyFriends' has been installed"
Write-Host ""

Write-Host "Cleaning up download cache..."
Remove-Item -Path "$ror2_dir\downloads" -Recurse

Write-Host ""
Write-Host "All done!"
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');