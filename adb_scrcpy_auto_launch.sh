#!/bin/bash

# This Bash script will continuously attempt to connect to an ADB device.
# It's designed to run in an infinite loop until a successful and authorized
# connection is established, after which Scrcpy is launched.
#
# IMPORTANT:
# - Ensure ADB and Scrcpy are installed and available in your system's PATH.
#   (e.g., via 'sudo apt install adb scrcpy' on Debian/Ubuntu)
# - This script will run indefinitely until you manually stop it (e.g., by pressing Ctrl+C in the terminal)
#   or until Scrcpy is successfully launched after authorization.
# - Make sure you have consent from the device owner to attempt this connection.

# Define the path for the configuration file
# Gets the directory where the script itself is located
scriptDir="$(dirname "$(readlink -f "$0")")"
configFilePath="${scriptDir}/adb_config.txt"

# Variables to store Device IP and audio preference
targetDevice=""
useAudio="" # New variable for audio preference

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
    done # Corrected: 'done' instead of '}'
}

# --- Load or prompt for device IP and audio preference ---
# Read config into a temporary associative array
declare -A loaded_config
while IFS='=' read -r key value; do
    loaded_config["$key"]="$value"
done < <(read_config "$configFilePath") # Use process substitution to feed function output to while loop

# Assign loaded values, default to empty string if not found
targetDevice="${loaded_config["TargetDevice"]}"
useAudio="${loaded_config["UseAudio"]}" # Load audio preference

# Validate and prompt for Target Device IP
if [[ -z "$targetDevice" ]]; then # Check if targetDevice is empty
    echo -e "\e[31mAndroid TV device IP address not found in configuration.\e[0m"
    read -p "Please enter your Android TV's IP address and port (e.g., 192.168.8.93:5555): " targetDevice
    while [[ -z "$targetDevice" ]]; do # Loop until a non-empty value is provided
        echo -e "\e[31mInvalid input. Device IP cannot be empty.\e[0m"
        read -p "Please re-enter your Android TV's IP address and port: " targetDevice
    done
fi

# Prompt for audio preference if not set or if user wants to change
if [[ -z "$useAudio" ]]; then
    echo -e "\e[34mAudio preference not found in configuration.\e[0m"
    read -p "Do you want audio with Scrcpy? (y/N): " audioChoice
    audioChoice=${audioChoice:-n} # Default to 'n' if no input
    if [[ "$audioChoice" =~ ^[Yy]$ ]]; then
        useAudio="true"
        echo -e "\e[32mAudio enabled for Scrcpy.\e[0m"
    else
        useAudio="false"
        echo -e "\e[32mAudio disabled for Scrcpy.\e[0m"
    fi
fi

# Save updated device IP and audio preference to config file
declare -A current_config=(
    ["TargetDevice"]="$targetDevice"
    ["UseAudio"]="$useAudio" # Save audio preference
)
write_config "$configFilePath" current_config
echo -e "\e[32mConfiguration saved to '$configFilePath' for future use.\e[0m"

# --- Start of Connection Loop ---
while true; do
    echo -e "\e[36m--- Attempting ADB Connection ---\e[0m"

    # Step 1: Kill the ADB server to ensure a clean start
    echo -e "\e[33mKilling ADB server...\e[0m"
    # Rely on 'adb' being in PATH
    adb kill-server > /dev/null 2>&1

    # Add a small delay to ensure the server has time to stop
    sleep 1

    # Step 2: Attempt to connect to the device
    echo -e "\e[33mAttempting to connect to $targetDevice...\e[0m"
    # Rely on 'adb' being in PATH
    connectOutput=$(adb connect "$targetDevice" 2>&1)
    echo "$connectOutput"

    # Add a small delay to allow ADB daemon to update device list
    sleep 1

    # Step 3: Check the actual device status using 'adb devices'
    echo -e "\e[33mChecking device authorization status...\e[0m"
    # Rely on 'adb' being in PATH
    deviceList=$(adb devices 2>&1)
    echo "$deviceList"

    # Check if the target device is listed as 'device' (fully authorized and connected)
    if echo "$deviceList" | grep -q "$targetDevice[[:space:]]\+device"; then
        echo -e "\e[32mDevice is authorized and connected! Launching Scrcpy...\e[0m"
        
        # Construct Scrcpy command based on audio preference
        scrcpyCommand="scrcpy -s \"$targetDevice\""
        if [[ "$useAudio" == "false" ]]; then
            scrcpyCommand+=" --no-audio"
        fi

        # Launch Scrcpy executable, explicitly selecting the target TCP/IP device by its serial/identifier
        # Use sudo -u "$SUDO_USER" to run scrcpy as the original user, preserving graphical environment variables
        sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" bash -c "$scrcpyCommand"
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
