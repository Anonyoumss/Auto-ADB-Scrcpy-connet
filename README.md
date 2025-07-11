# Auto-ADB-Scrcpy-connet
Auto-ADB-Scrcpy-connet: PowerShell scripts for automating ADB connection and Scrcpy launch for Android Devices TV/Phone/Tablet e.t.c !

Auto ADB connect 
# REQUIREMENTS
Android Debug Bridge (adb): https://developer.android.com/tools/adb

scrcpy: https://github.com/Genymobile/scrcpy

# How to use this  script:
# LINUX
Make it Executable:

Open your terminal.

Navigate to the directory where you saved the script using cd.

Run the command to make it executable:

Bash

chmod +x adb_auto_connect.sh
Run the script:

In the terminal, execute the script:

Bash

./adb_auto_connect.sh
Important Notes for Linux:

ADB Installation: Ensure ADB is installed on your Ubuntu system. You can usually install it via your package manager: sudo apt install adb. If you install it this way, adb will likely be in your system's PATH, and you might be able to use just adb instead of $adbPath/adb in the script (but keeping $adbPath makes it more robust if ADB isn't in PATH).
Scrcpy Installation: Install Scrcpy. On Ubuntu, you can typically install it with: sudo apt install scrcpy. Again, if installed this way, scrcpy will be in your PATH.


# Windows
Save the code: Copy the entire updated code and replace the content of your adb_auto_connect.ps1 file with it.

Run the script: Execute the script in PowerShell as usual (.\adb_auto_connect.ps1).

First run: The first time you run it (or if adb_config.txt is missing/empty), it will prompt you to enter the full paths for your ADB platform-tools and Scrcpy directories.

Future runs: After you've entered the paths once, they will be saved in adb_config.txt, and the script will automatically read them from there on subsequent runs.

# IMPORTANT:
 - Ensure your ADB platform-tools directory is correct.
 - Ensure your Scrcpy directory is correct.
 - This script will run indefinitely until you manually stop it (e.g., by pressing Ctrl+C in the PowerShell window)
   or until Scrcpy is successfully launched after authorization.
- Make sure you have consent from the device owner to attempt this connection.

  # USE Cases
  1.Auto connect to Device
  
  2.Auto connect and launch scrcpy
  
  3.Annoy Friend/Sibling

# scrcpy shortcuts 
https://github.com/Genymobile/scrcpy/blob/master/doc/shortcuts.md
