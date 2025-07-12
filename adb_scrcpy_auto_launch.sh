#!/bin/bash

# This Bash script will continuously attempt to connect to an ADB device.
# It's designed to run in an infinite loop until a successful and authorized
# connection is established, after which Scrcpy is launched.
#
# IMPORTANT:
# - Ensure your ADB platform-tools directory is correct and ADB is executable.
# - Ensure your Scrcpy directory is correct and Scrcpy is executable.
# - This script will run indefinitely until you manually stop it (e.g., by pressing Ctrl+C in the terminal)
#   or until Scrcpy is successfully launched after authorization.
# - Make sure you have consent from the device owner to attempt this connection.

# Define the target IP address and port for your Android TV
targetDevice="" # This will be loaded from config or prompted

# Define the path for the configuration file
# Gets the directory where the script itself is located
scriptDir="$(dirname "$(readlink -f "$0")")"
configFilePath="${scriptDir}/adb_config.txt"

# Variables to store ADB and Scrcpy paths
adbPath=""
scrcpyPath=""

# Default paths for common installations on Linux
defaultAdbPath="/usr/bin"
defaultScrcpyPath="/usr/local/bin" # Or sometimes /usr/bin

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

# --- Load or prompt for paths and device IP ---
# Read config into a temporary associative array
declare -A loaded_config
while IFS='=' read -r key value; do
    loaded_config["$key"]="$value"
done < <(read_config "$configFilePath") # Use process substitution to feed function output to while loop

# Assign loaded values, default to empty string if not found
adbPath="${loaded_config["AdbPath"]}"
scrcpyPath="${loaded_config["ScrcpyPath"]}"
targetDevice="${loaded_config["TargetDevice"]}"

# --- Prompt for default paths or manual input ---
if [[ ! -x "$adbPath/adb" || ! -x "$scrcpyPath/scrcpy" ]]; then
    echo -e "\e[34mConfiguration paths not found or executables are missing.\e[0m"
    read -p "Do you want to use default paths? (ADB: $defaultAdbPath, Scrcpy: $defaultScrcpyPath) [y/N]: " useDefaults
    useDefaults=${useDefaults:-n} # Default to 'n' if no input

    if [[ "$useDefaults" =~ ^[Yy]$ ]]; then
        adbPath="$defaultAdbPath"
        scrcpyPath="$defaultScrcpyPath"
        echo -e "\e[32mUsing default paths.\e[0m"
    else
        # Validate and prompt for ADB path
        if [[ ! -x "$adbPath/adb" ]]; then
            echo -e "\e[31mADB platform-tools path not found or 'adb' is not executable.\e[0m"
            read -p "Please enter the full path to your ADB platform-tools directory (e.g., /home/youruser/platform-tools): " adbPath
            while [[ ! -x "$adbPath/adb" ]]; do
                echo -e "\e[31mInvalid path. 'adb' not found or not executable at '$adbPath'.\e[0m"
                read -p "Please re-enter the correct path to your ADB platform-tools directory: " adbPath
            done
        fi

        # Validate and prompt for Scrcpy path
        if [[ ! -x "$scrcpyPath/scrcpy" ]]; then
            echo -e "\e[31mScrcpy executable path not found or 'scrcpy' is not executable.\e[0m"
            read -p "Please enter the full path to your Scrcpy directory (e.g., /home/youruser/scrcpy-folder): " scrcpyPath
            while [[ ! -x "$scrcpyPath/scrcpy" ]]; do
                echo -e "\e[31mInvalid path. 'scrcpy' not found or not executable at '$scrcpyPath'.\e[0m"
                read -p "Please re-enter the correct path to your Scrcpy directory: " scrcpyPath
            done
        fi
    fi
fi

# Validate and prompt for Target Device IP
if [[ -z "$targetDevice" ]]; then # Check if targetDevice is empty
    echo -e "\e[31mAndroid TV device IP address not found.\e[0m"
    read -p "Please enter your Android TV's IP address and port (e.g., 192.168.8.93:5555): " targetDevice
    while [[ -z "$targetDevice" ]]; do # Loop until a non-empty value is provided
        echo -e "\e[31mInvalid input. Device IP cannot be empty.\e[0m"
        read -p "Please re-enter your Android TV's IP address and port: " targetDevice
    done
fi

# Save updated paths and device IP to config file
declare -A current_config=(
    ["AdbPath"]="$adbPath"
    ["ScrcpyPath"]="$scrcpyPath"
    ["TargetDevice"]="$targetDevice"
)
write_config "$configFilePath" current_config
echo -e "\e[32mConfiguration saved to '$configFilePath' for future use.\e[0m"

# --- Start of Connection Loop ---
while true; do
    echo -e "\e[36m--- Attempting ADB Connection ---\e[0m"

    # Step 1: Kill the ADB server to ensure a clean start
    echo -e "\e[33mKilling ADB server...\e[0m"
    "$adbPath/adb" kill-server > /dev/null 2>&1

    # Add a small delay to ensure the server has time to stop
    sleep 1

    # Step 2: Attempt to connect to the device
    echo -e "\e[33mAttempting to connect to $targetDevice...\e[0m"
    connectOutput=$("$adbPath/adb" connect "$targetDevice" 2>&1)
    echo "$connectOutput"

    # Add a small delay to allow ADB daemon to update device list
    sleep 1

    # Step 3: Check the actual device status using 'adb devices'
    echo -e "\e[33mChecking device authorization status...\e[0m"
    deviceList=$("$adbPath/adb" devices 2>&1)
    echo "$deviceList"

    # Check if the target device is listed as 'device' (fully authorized and connected)
    if echo "$deviceList" | grep -q "$targetDevice[[:space:]]\+device"; then
        echo -e "\e[32mDevice is authorized and connected! Launching Scrcpy...\e[0m"
        "$scrcpyPath/scrcpy" # Launch Scrcpy executable from its directory
        break # Exit the loop since Scrcpy has been launched successfully
    elif echo "$deviceList" | grep -q "$targetDevice[[:space:]]\+unauthorized"; then
        echo -e "\e[33mDevice is unauthorized. Please accept the 'Allow USB debugging?' prompt on your TV screen. Retrying in 2 seconds...\e[0m"
        sleep 2
    else
        echo -e "\e[31mDevice not found or connection failed for another reason. Retrying in 2 seconds...\e[0m"
        sleep 2
    fi
done

echo -e "\e[32mScript finished.\e[0m"
