#!/bin/bash

# This Bash script will continuously attempt to connect to an ADB device.
# It's designed to run in an infinite loop until a successful and authorized
# connection is established. It does NOT launch Scrcpy directly, but it
# now prompts for and saves both ADB and Scrcpy paths for future use.
#
# IMPORTANT:
# - Ensure your ADB platform-tools directory is correct and ADB is executable.
# - This script will run indefinitely until you manually stop it (e.g., by pressing Ctrl+C in the terminal).
# - Make sure you have consent from the device owner to attempt this connection.

# Define the target IP address and port for your Android TV
targetDevice="192.168.8.93:5555"

# Define the path for the configuration file
# Gets the directory where the script itself is located
scriptDir="$(dirname "$(readlink -f "$0")")"
configFilePath="${scriptDir}/adb_config.txt"

# Variables to store ADB and Scrcpy paths
adbPath=""
scrcpyPath="" # Scrcpy path is stored for consistency with future scripts

# --- Function to read configuration from file ---
# Reads key=value pairs into an associative array
read_config() {
    local path="$1"
    declare -A config_map # Declare an associative array
    if [[ -f "$path" ]]; then
        while IFS='=' read -r key value; do
            # Ensure key and value are not empty
            if [[ -n "$key" && -n "$value" ]]; then
                config_map["$key"]="$value"
            fi
        done < "$path"
    fi
    # Return the associative array by printing its contents
    # This is a common Bash pattern for returning maps/arrays from functions
    for key in "${!config_map[@]}"; do
        echo "$key=${config_map[$key]}"
    done
}

# --- Function to write configuration to file ---
# Writes key=value pairs from an associative array to a file
write_config() {
    local path="$1"
    local -n config_data="$2" # Nameref to the associative array passed as argument
    > "$path" # Clear the file before writing
    for key in "${!config_data[@]}"; do
        echo "$key=${config_data[$key]}" >> "$path"
    done
}

# --- Load or prompt for paths ---
# Read config into a temporary associative array
declare -A loaded_config
while IFS='=' read -r key value; do
    loaded_config["$key"]="$value"
done < <(read_config "$configFilePath") # Use process substitution to feed function output to while loop

# Assign loaded values, default to empty string if not found
adbPath="${loaded_config["AdbPath"]}"
scrcpyPath="${loaded_config["ScrcpyPath"]}"

# Validate and prompt for ADB path
# Check if 'adb' executable exists and is executable at the stored path
if [[ ! -x "$adbPath/adb" ]]; then
    echo -e "\e[31mADB platform-tools path not found or 'adb' is not executable.\e[0m"
    read -p "Please enter the full path to your ADB platform-tools directory (e.g., /home/youruser/platform-tools): " adbPath
    # Basic validation loop: keep asking until a valid executable is found
    while [[ ! -x "$adbPath/adb" ]]; do
        echo -e "\e[31mInvalid path. 'adb' not found or not executable at '$adbPath'.\e[0m"
        read -p "Please re-enter the correct path to your ADB platform-tools directory: " adbPath
    done
fi

# Validate and prompt for Scrcpy path (even if this script doesn't use it directly, for consistency)
# Check if 'scrcpy' executable exists and is executable at the stored path
if [[ ! -x "$scrcpyPath/scrcpy" ]]; then
    echo -e "\e[31mScrcpy executable path not found or 'scrcpy' is not executable.\e[0m"
    read -p "Please enter the full path to your Scrcpy directory (e.g., /home/youruser/scrcpy-folder): " scrcpyPath
    # Basic validation loop: keep asking until a valid executable is found
    while [[ ! -x "$scrcpyPath/scrcpy" ]]; do
        echo -e "\e[31mInvalid path. 'scrcpy' not found or not executable at '$scrcpyPath'.\e[0m"
        read -p "Please re-enter the correct path to your Scrcpy directory: " scrcpyPath
    done
fi

# Save updated paths to config file
declare -A current_config=( ["AdbPath"]="$adbPath" ["ScrcpyPath"]="$scrcpyPath" )
write_config "$configFilePath" current_config # Pass the associative array by name
echo -e "\e[32mPaths saved to '$configFilePath' for future use.\e[0m"

# --- Start of Connection Loop ---
while true; do
    echo -e "\e[36m--- Attempting ADB Connection ---\e[0m"

    # Step 1: Kill the ADB server to ensure a clean start
    echo -e "\e[33mKilling ADB server...\e[0m"
    # Redirect stdout and stderr to /dev/null to suppress output
    "$adbPath/adb" kill-server > /dev/null 2>&1

    # Add a small delay to ensure the server has time to stop
    sleep 1

    # Step 2: Attempt to connect to the device
    echo -e "\e[33mAttempting to connect to $targetDevice...\e[0m"
    # Capture all output (stdout and stderr) from the connect command
    connectOutput=$("$adbPath/adb" connect "$targetDevice" 2>&1)
    echo "$connectOutput"

    # Add a small delay to allow ADB daemon to update device list
    sleep 1

    # Step 3: Check the actual device status using 'adb devices'
    echo -e "\e[33mChecking device authorization status...\e[0m"
    # Capture all output from the devices command
    deviceList=$("$adbPath/adb" devices 2>&1)
    echo "$deviceList"

    # Check if the target device is listed as 'device' (fully authorized and connected)
    # The `grep -q` command checks if the pattern exists silently
    if echo "$deviceList" | grep -q "$targetDevice[[:space:]]\+device"; then
        echo -e "\e[32mDevice is authorized and connected! You can now run Scrcpy manually.\e[0m"
        # Exit the loop since the connection is authorized
        break
    elif echo "$deviceList" | grep -q "$targetDevice[[:space:]]\+unauthorized"; then
        echo -e "\e[33mDevice is unauthorized. Please accept the 'Allow USB debugging?' prompt on your TV screen. Retrying in 2 seconds...\e[0m"
        # No break here, continue looping to allow the user time to authorize on the device
        sleep 2
    else
        echo -e "\e[31mDevice not found or connection failed for another reason. Retrying in 2 seconds...\e[0m"
        # Add a delay before the next iteration if connection failed or device not found
        sleep 2
    fi
done

echo -e "\e[32mADB auto-connect script finished.\e[0m"
