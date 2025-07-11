# Auto-ADB-Scrcpy-connet
Auto-ADB-Scrcpy-connet: PowerShell scripts for automating ADB connection and Scrcpy launch for Android Devices TV/Phone/Tablet e.t.c !

Auto ADB connect 
# REQUIREMENTS
Android Debug Bridge (adb): https://developer.android.com/tools/adb

scrcpy: https://github.com/Genymobile/scrcpy

# How to use this updated script:

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
