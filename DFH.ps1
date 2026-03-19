# Dion's Framerate Hook
# Script made by RocketSmash9000
# Modifies the maximum framerate at which Project Turboblast can run
# Needs to be run manually once, then will run automatically on user login
# To run this script, do powershell.exe -noexit -ExecutionPolicy Bypass -File "C:\path\to\DFH.ps1"
# on the run dialog (Win + R) or CMD

# === Setup ===

param([switch]$Auto)

$path = Join-Path $env:LOCALAPPDATA "PTB_2024\Saved\Config\Windows\GameUserSettings.ini"
$path_settings = Join-Path $env:LOCALAPPDATA "PTB_2024\Saved\Config\Windows\DFH.cfg"
$startup = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startup "DFH.lnk"

# === Code Execution ===

# If the script has been manually run, run this part
if (-not $Auto) {
    cls # Clear the console
	Write-Host
	Write-Host "     ======---> Dion's Framerate Hook <---======"
	Write-Host

	# Something something code that does the framerate changing below
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

	# If path to config file exists
	if ( Test-Path -Path $path_settings -PathType Leaf ) {
		Write-Host "Gonfig file exists! Reading..."
		$content = @(Get-Content $path_settings)
		# Select-String searches the file for the pattern and returns the matching line
		$match = Select-String -Path $path_settings -Pattern "FrameRateLimit"
		
		if ($match) {
			$target = $match.Line
		}
		
		Write-Host ( "Framerate to replace with: " + $target )
		
		$decision = Read-Host "Are you sure you want to proceed? [Y/N]"
		
		if ( $decision -ne "y" ) {
			$decision = Read-Host "Do you want to change framerate? [Y/N]"
			if ( $decision -ne "y" ) {
				Write-Host "Nothing will be changed then"
				exit
			}
			else {
				Write-Host "Setting maximum framerate to less than 40 will lead to weird physics"
				$target = Read-Host "What do you want the maximum framerate to be?"
				$target = "FrameRateLimit=" + $target + ".000000"
				
				Write-Host ( "Setting to be replaced with: " + $target )
				
				$decision = Read-Host "Are you sure you want to proceed? [Y/N]"
				
				if ( $decision -ne "y" ) {
					Write-Host "Nothing will be changed then"
					exit
				}
			}
		}
	}
	# If it doesn't...
	else {
		Write-Host "No config file exists. Creating one..."
		# Create config file
		New-Item -Path $path_settings -ItemType File

		# Get the target max framerate
		Write-Host "Setting maximum framerate to less than 40 will lead to weird physics"
		$target = Read-Host "What do you want the maximum framerate to be?"

		$target = "FrameRateLimit=" + $target + ".000000"
		
		Write-Host ( "Setting to be replaced with: " + $target )
		
		$decision = Read-Host "Are you sure you want to proceed? [Y/N]"
		
		if ( $decision -ne "y" ) {
			Write-Host "Nothing will be changed then"
			exit
		}
	}
	
	$content = Get-Content $path -Raw

	# Replace the default fps by the target fps
	$content = $content -replace "FrameRateLimit=[\d.]+", $target
	Set-Content $path $content -Encoding UTF8 -NoNewline
	Write-Host "Wrote target FPS to game config"
	
	# Write target fps to config file
	Set-Content $path_settings $target -Encoding UTF8
	Write-Host "Wrote target FPS to config file"
	
	# If the script isn't set to run at startup, add it
	if (-not (Test-Path $shortcutPath)) {
		$WshShell = New-Object -ComObject WScript.Shell
		$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\DFH.lnk"

		# Create a VBScript wrapper that launches PowerShell hidden
		$vbsPath = "$env:TEMP\LaunchPowerShell.vbs"
		$vbsContent = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""$PSCommandPath"" -Auto", 0, False
"@

		Set-Content -Path $vbsPath -Value $vbsContent -Encoding ASCII

		# Create shortcut to VBScript instead
		$shortcut = $WshShell.CreateShortcut($shortcutPath)
		$shortcut.TargetPath = "wscript.exe"
		$shortcut.Arguments = "`"$vbsPath`""
		$shortcut.WorkingDirectory = Split-Path $PSCommandPath
		$shortcut.Save()

		Write-Host "Startup shortcut created"
		Write-Host "Please log off and on again for the script to automatically start"
	}
	else {
		Write-Host "Shortcut already exists. Not touching it"
	}
}
# If in automatic mode, listen to PTB execution
else {
	$processName = "PTB_2024"
	$wasRunning = $false

	while ($true) {
		$isRunning = Get-Process -Name $processName -ErrorAction SilentlyContinue

		if ($isRunning) {
			$wasRunning = $true
		}
		else {
			if ($wasRunning) {
				Start-Sleep -Seconds 10
				Write-Host "Game closed. Reapplying framerate..."
				
				$content = @(Get-Content $path_settings)
				# Select-String searches the file for the pattern and returns the matching line
				$match = Select-String -Path $path_settings -Pattern "FrameRateLimit"
				
				if ($match) {
					$target = $match.Line
					$content = Get-Content $path -Raw
					# Replace the default fps by the target fps
					$content = $content -replace "FrameRateLimit=[\d.]+", $target
					Set-Content $path $content -Encoding UTF8 -NoNewline
					Write-Host "Wrote target FPS to game config"

					Write-Host "Framerate restored."
					$wasRunning = $false
				}
			}
		}

		Start-Sleep -Seconds 15
	}
}