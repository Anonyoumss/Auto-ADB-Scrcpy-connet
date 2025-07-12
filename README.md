# Auto-ADB-Scrcpy-connect

This repository contains PowerShell and Bash scripts designed to streamline the process of connecting to your Android devices (TVs, Phones, Tablets, etc.) via ADB (Android Debug Bridge) and launching Scrcpy for screen mirroring/control.

---


## 1️⃣ Windows Setup

<details>
<summary>Expand for Windows instructions</summary>

### Step 1: Save the Scripts

Copy the content of the PowerShell scripts:

- `adb_auto_connect.ps1`
- `adb_scrcpy_auto_launch.ps1`

Save them in a convenient folder (e.g., `C:\Scripts`).

### Step 2: Run PowerShell as Administrator (if needed)

Open PowerShell and navigate to your scripts folder:

```powershell
cd C:\Scripts
```

### Step 3: Make Execution Policy Allow Scripts (if needed)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 4: Run the Desired Script

For auto-connect:

```powershell
.\adb_auto_connect.ps1
```

### Step 5: First-Run Prompts

- On first run (or if `adb_config.txt` is missing), you will be prompted to use default paths for ADB and Scrcpy.
- If you choose **Y (Yes)**, it will attempt to use default locations.
- If you choose **N (No)**, you can specify custom locations.

</details>

---

## 2️⃣ Mac Setup

<details>
<summary>Expand for Mac instructions</summary>

### Step 1: Save the Scripts

Copy the content of the Bash scripts:

- `adb_auto_connect.sh`
- `adb_scrcpy_auto_launch.sh`

Save them in a convenient folder (e.g., `~/Documents/scripts/`).

### Step 2: Make the Scripts Executable

```bash
chmod +x adb_auto_connect.sh adb_scrcpy_auto_launch.sh
```

### Step 3: Run in Terminal

Navigate to your scripts folder and run the desired script:

```bash
./adb_auto_connect.sh
```

### Step 4: First-Run Prompts

- On first run (or if `adb_config.txt` is missing), you will be prompted for your Android device's IP address and port (e.g., `192.168.8.93:5555`).
- This will be saved in `adb_config.txt` for future runs.

</details>

---

## 3️⃣ Linux Setup

<details>
<summary>Expand for Linux instructions</summary>

### Step 1: Ensure ADB Permissions

Make sure your user is part of the `plugdev` group for ADB permissions:

```bash
sudo usermod -aG plugdev $USER
# Log out and back in for group changes to take effect
```

### Step 2: Save the Scripts

Copy the content of the Bash scripts:

- `adb_auto_connect.sh`
- `adb_scrcpy_auto_launch.sh`

Save them in a convenient folder (e.g., `~/scripts/`).

### Step 3: Make the Scripts Executable

```bash
chmod +x adb_auto_connect.sh adb_scrcpy_auto_launch.sh
```

### Step 4: Run in Terminal

Navigate to your scripts folder and run the desired script:

```bash
./adb_auto_connect.sh
```

### Step 5: First-Run Prompts

- On first run (or if `adb_config.txt` is missing), you will be prompted for your Android device's IP address and port.
- This will be saved in `adb_config.txt` for future runs.

</details>

---

## 4️⃣ Common Troubleshooting

- **ADB Not Found:** Ensure ADB is installed and in your system PATH, or specify the path when prompted.
- **Scrcpy Not Found:** Ensure Scrcpy is installed and in your system PATH, or specify the path when prompted.
- **Permission Errors (Linux/Mac):** Make scripts executable (`chmod +x ...`) and check ADB user group membership.
- **Device Not Connecting:** Confirm the device is on the same network and ADB debugging is enabled.

---

## 🔗 Resources

- [ADB Documentation](https://developer.android.com/studio/command-line/adb)
- [Scrcpy GitHub](https://github.com/Genymobile/scrcpy)

---

Made with ❤️ by [Anonyoums]. PRs and feedback welcome!
