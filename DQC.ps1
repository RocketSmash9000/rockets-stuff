# Dion's Quality Control
# Script made by RocketSmash9000
# Modifies the non-HUD quality of rendered elements in PTB
# Less quality = more frames and more pixelated screen
# The quality uses percentage, so 100 is same resolution as monitor
# 50 means half the monitor's resolution
# and 1 is 1% of the monitor's resolution

# === Setup ===
$path = Join-Path $env:LOCALAPPDATA "PTB_2024\Saved\Config\Windows\GameUserSettings.ini"

# === Code ===
cls
Write-Host
Write-Host "     ======---> Dion's Quality Control <---======"
Write-Host

Write-Host "Run at your own risk! Read what this file does before executing it"
Write-Host "Ensure that you know what the script does, or ask ChatGPT"
Write-Host "This script modifies game settings. Make a copy of the file beforehand"
Write-Host "The game config is located at %LOCALAPPDATA%\PTB_2024\Saved\Config\Windows"
Write-Host "If you don't want to run this script yet, press N"
$decision = Read-Host "Do you still want to run this script? [Y/N]"

if ( $decision -ne "y" ) {
	Write-Host "The script will exit now"
	exit
}

cls
Write-Host
Write-Host "     ======---> Dion's Quality Control <---======"
Write-Host
Write-Host "In Pandamonium's words, lowering the quality makes it harder to see at high speeds"
Write-Host "The quality parameter is a percentage relative yo your monitor's resolution"
Write-Host "If you have a 1440p monitor, setting the quality to 50 will render at around 1080p"
Write-Host "This means that if you use a 1080p monitor, setting this value to 50 will render at around 720p"
Write-Host "It's recommended that you don't go below 40 in 1440p monitors and 60 in 1080p monitors"
Write-Host "Setting to 0 or 100 will render at your monitor's resolution"

$target = Read-Host "What do you want the quality to be?"
$target = "sg.ResolutionQuality=" + $target

Write-Host ( "Setting to be replaced with: " + $target )

$decision = Read-Host "Are you sure you want to proceed? [Y/N]"

if ( $decision -ne "y" ) {
	Write-Host "Nothing will be changed then"
	exit
}

$content = Get-Content $path -Raw

# Replace the default quality by the target one
$content = $content -replace "sg.ResolutionQuality=[\d.]+", $target
Set-Content $path $content -Encoding UTF8 -NoNewline
Write-Host "Wrote target FPS to game config"

Write-Host
Write-Host "PTB shouldn't change this setting back to 0. If it does change, rerun the script"