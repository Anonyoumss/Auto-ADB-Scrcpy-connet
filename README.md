# Auto-ADB-Scrcpy-connet

PowerShell and Bash scripts to streamline connecting your Android devices (TVs, Phones, Tablets, etc.) via ADB and launching [Scrcpy](https://github.com/Genymobile/scrcpy) for screen mirroring or control.

---

## 📦 Installation

Click your platform to jump to setup instructions:

<p align="center">
  <a href="#chromeos-setup"><img src="https://img.icons8.com/?size=100&id=JOT4OHXaiQRT&format=png&color=000000" alt="ChromeOS" title="ChromeOS" /></a>
    <a href="#linux-setup"><img src="https://img.icons8.com/?size=100&id=tmEqIUErLJVM&format=png&color=000000" alt="Linux" title="Linux" /></a>
  <a href="#windows-setup"><img src="https://img.icons8.com/?size=100&id=rGPimU4LglXL&format=png&color=000000" alt="Windows" title="Windows" /></a>
    <a href="#macos-setup"><img src="https://img.icons8.com/?size=100&id=122959&format=png&color=000000" alt="macOS" title="macOS" /></a>

</p>

---

### <a name="chromeos-setup"></a> ChromeOS Setup

1. **Enable Linux (Beta)** on your Chromebook.
2. **Install ADB and Scrcpy:**
   ```sh
   sudo apt update
   sudo apt install adb scrcpy
   ```
3. **Clone this repository:**
   ```sh
   git clone https://github.com/Anonyoumss/Auto-ADB-Scrcpy-connet.git
   cd Auto-ADB-Scrcpy-connet
   ```
4. **Make scripts executable:**
   ```sh
   chmod +x adb_auto_connect.sh adb_scrcpy_auto_launch.sh
   ```
5. **Run your desired script:**
   ```sh
   ./adb_auto_connect.sh
   # or
   ./adb_scrcpy_auto_launch.sh
   ```
6. **First-Time Setup:**  
   The script will prompt for your Android device's IP and port (e.g., `192.168.8.93:5555`). This info is saved to `adb_config.txt` for future use.

---



### <a name="linux-setup"></a> Linux Setup

1. **Install ADB and Scrcpy:**
   ```sh
   sudo apt update
   sudo apt install adb scrcpy
   ```
   _For other distros, use your package manager (e.g., `yum`, `dnf`, `pacman`)._
2. **Ensure your user is in the `plugdev` group** (for ADB permissions):
   ```sh
   sudo usermod -aG plugdev $USER
   # Log out and back in for group changes to take effect
   ```
3. **Clone this repository:**
   ```sh
   git clone https://github.com/Anonyoumss/Auto-ADB-Scrcpy-connet.git
   cd Auto-ADB-Scrcpy-connet
   ```
4. **Make scripts executable:**
   ```sh
   chmod +x adb_auto_connect.sh adb_scrcpy_auto_launch.sh
   ```
5. **Run your desired script:**
   ```sh
   ./adb_auto_connect.sh
   # or
   ./adb_scrcpy_auto_launch.sh
   ```
6. **First-Time Setup:**  
   The script will prompt for your Android device IP and port. This is saved in `adb_config.txt` for future use.

---
### <a name="windows-setup"></a>🪟 Windows Setup

1. **Download and install:**
   - [ADB (Android Platform Tools)](https://developer.android.com/tools/releases/platform-tools)
   - [Scrcpy](https://github.com/Genymobile/scrcpy/releases)
2. **Add ADB and Scrcpy to your PATH** for global access.
3. **Clone or download this repository:**
   ```sh
   git clone https://github.com/Anonyoumss/Auto-ADB-Scrcpy-connet.git
   cd Auto-ADB-Scrcpy-connet
   ```
4. **Run PowerShell script:**  
   Double-click `adb_auto_connect.ps1` or run it in PowerShell:
   ```powershell
   .\adb_auto_connect.ps1
   # or
   .\adb_scrcpy_auto_launch.ps1
   ```
5. **First-Time Setup:**  
   On first run (or if `adb_config.txt` is missing), you’ll be prompted for ADB/Scrcpy locations and device IP/port. These are saved for future runs.

---
### <a name="macos-setup"></a>🍎 macOS Setup

1. **Install Homebrew** (if not installed):
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. **Install ADB and Scrcpy:**
   ```sh
   brew install android-platform-tools scrcpy
   ```
3. **Clone this repository:**
   ```sh
   git clone https://github.com/Anonyoumss/Auto-ADB-Scrcpy-connet.git
   cd Auto-ADB-Scrcpy-connet
   ```
4. **Make scripts executable:**
   ```sh
   chmod +x adb_auto_connect.sh adb_scrcpy_auto_launch.sh
   ```
5. **Run your desired script:**
   ```sh
   ./adb_auto_connect.sh
   # or
   ./adb_scrcpy_auto_launch.sh
   ```
6. **First-Time Setup:**  
   The script will prompt for your device's IP and port. This info is saved for later runs.

---

## 🚀 Usage

1. **Connect your Android device** (via USB or ensure it is on the same Wi-Fi network).
2. **Run the appropriate script** for your OS as described above.
3. **Follow any on-screen prompts** (first time only).
4. **Scrcpy will launch automatically** after ADB connection.

---

## Use cases

1. **Auto-Connect your Android device**.
2. **Annoy Friends/Family** (By blasting the conform message).
3. **Parental Control** (Watch what your kids are watching and change it).
4. **CCTV** (by mirrint the CCTV/Connecting a USB camera and using USB Camera App).

---

## 🛠️ Features

- Automates ADB device connection (USB or Wi-Fi)
- One-click Scrcpy launch
- Remembers device info for faster future connections
- Cross-platform: PowerShell (Windows) and Bash (macOS/Linux/ChromeOS)

---



## 🤝 Contributing

Pull requests and issues are welcome!

---

