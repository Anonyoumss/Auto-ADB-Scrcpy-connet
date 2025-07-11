# This PowerShell script will continuously attempt to connect to an ADB device.
# It's designed to run in an infinite loop until a successful and authorized
# connection is established. It does NOT launch Scrcpy directly, but it
# now prompts for and saves ADB, Scrcpy, and Device IP paths for future use.
#
# IMPORTANT:
# - Ensure your ADB platform-tools directory is correct and ADB is executable.
# - This script will run indefinitely until you manually stop it (e.g., by pressing Ctrl+C in the PowerShell window).
# - Make sure you have consent from the device owner to attempt this connection.

# Define the path for the configuration file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$configFilePath = Join-Path $scriptDir "adb_config.txt"

# Variables to store ADB, Scrcpy, and Device IP
$adbPath = ""
$scrcpyPath = ""
$targetDevice = ""

# --- Function to read configuration from file ---
function Read-AdbConfig {
    param (
        [string]$Path
    )
    $config = @{}
    if (Test-Path $Path) {
        Get-Content $Path | ForEach-Object {
            if ($_ -match "^(.+?)=(.+)$") {
                $config[$Matches[1]] = $Matches[2]
            }
        }
    }
    return $config
}

# --- Function to write configuration to file ---
function Write-AdbConfig {
    param (
        [string]$Path,
        [hashtable]$ConfigData
    )
    $ConfigData.Keys | ForEach-Object {
        "$_=$($ConfigData[$_])"
    } | Set-Content $Path
}

# --- Load or prompt for paths and device IP ---
$config = Read-AdbConfig $configFilePath

$adbPath = $config["AdbPath"]
$scrcpyPath = $config["ScrcpyPath"]
$targetDevice = $config["TargetDevice"] # Load target device

# Validate and prompt for ADB path
if (-not (Test-Path "$adbPath\adb.exe")) {
    Write-Host "ADB platform-tools path not found or 'adb.exe' is missing." -ForegroundColor Red
    $adbPath = Read-Host "Please enter the full path to your ADB platform-tools directory (e.g., C:\Users\YourName\Desktop\ADB\platform-tools)"
    # Basic validation loop
    while (-not (Test-Path "$adbPath\adb.exe")) {
        Write-Host "Invalid path. 'adb.exe' not found at '$adbPath'." -ForegroundColor Red
        $adbPath = Read-Host "Please re-enter the correct path to your ADB platform-tools directory"
    }
}

# Validate and prompt for Scrcpy path (even if this script doesn't use it directly, for consistency)
if (-not (Test-Path "$scrcpyPath\scrcpy.exe")) {
    Write-Host "Scrcpy executable path not found or 'scrcpy.exe' is missing." -ForegroundColor Red
    $scrcpyPath = Read-Host "Please enter the full path to your Scrcpy directory (e.g., C:\scrcpy\scrcpy-win64-v3.3.1)"
    # Basic validation loop
    while (-not (Test-Path "$scrcpyPath\scrcpy.exe")) {
        Write-Host "Invalid path. 'scrcpy.exe' not found at '$scrcpyPath'." -ForegroundColor Red
        $scrcpyPath = Read-Host "Please re-enter the correct path to your Scrcpy directory"
    }
}

# Validate and prompt for Target Device IP
if ([string]::IsNullOrEmpty($targetDevice)) { # Check if targetDevice is empty or null
    Write-Host "Android TV device IP address not found." -ForegroundColor Red
    $targetDevice = Read-Host "Please enter your Android TV's IP address and port (e.g., 192.168.8.93:5555)"
    # Loop until a non-empty value is provided
    while ([string]::IsNullOrEmpty($targetDevice)) {
        Write-Host "Invalid input. Device IP cannot be empty." -ForegroundColor Red
        $targetDevice = Read-Host "Please re-enter your Android TV's IP address and port"
    }
}

# Save updated paths and device IP to config file
$newConfig = @{
    "AdbPath" = $adbPath;
    "ScrcpyPath" = $scrcpyPath;
    "TargetDevice" = $targetDevice # Save target device
}
Write-AdbConfig $configFilePath $newConfig
Write-Host "Configuration saved to '$configFilePath' for future use." -ForegroundColor Green

# --- Start of Connection Loop ---
while ($true) {
    Write-Host "--- Attempting ADB Connection ---" -ForegroundColor Cyan

    # Step 1: Kill the ADB server to ensure a clean start
    Write-Host "Killing ADB server..." -ForegroundColor Yellow
    # Using Out-Null to suppress the output of kill-server for cleaner console
    & "$adbPath\adb.exe" kill-server | Out-Null

    # Add a small delay to ensure the server has time to stop
    Start-Sleep -Seconds 1

    # Step 2: Attempt to connect to the device
    # This command will also start the daemon if it's not running
    Write-Host "Attempting to connect to $targetDevice..." -ForegroundColor Yellow
    $connectOutput = & "$adbPath\adb.exe" connect $targetDevice | Out-String

    # Display the output from the ADB connect command
    Write-Host $connectOutput

    # Add a small delay to allow ADB daemon to update device list
    Start-Sleep -Seconds 1

    # Step 3: Check the actual device status using 'adb devices'
    Write-Host "Checking device authorization status..." -ForegroundColor Yellow
    $deviceList = & "$adbPath\adb.exe" devices | Out-String

    # Display the output from the ADB devices command
    Write-Host $deviceList

    # Check if the target device is listed as 'device' (fully authorized and connected)
    if ($deviceList -like "*`tdevice*") { # `t represents a tab character in PowerShell
        Write-Host "Device is authorized and connected! You can now run Scrcpy manually." -ForegroundColor Green
        # Exit the loop since the connection is authorized
        break
    } elseif ($deviceList -like "*`tunauthorized*") {
        Write-Host "Device is unauthorized. Please accept the 'Allow USB debugging?' prompt on your TV screen. Retrying in 2 seconds..." -ForegroundColor Yellow
        # No break here, continue looping to allow the user time to authorize on the device
        Start-Sleep -Seconds 2
    } else {
        Write-Host "Device not found or connection failed for another reason. Retrying in 2 seconds..." -ForegroundColor Red
        # Add a delay before the next iteration if connection failed or device not found
        Start-Sleep -Seconds 2
    }
}

Write-Host "ADB auto-connect script finished." -ForegroundColor Green
