# Windows Remote Desktop Connection to VM

Complete guide for connecting to a newly created VM using Windows Remote Desktop, including critical session sync requirements.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Initial Connection Setup](#initial-connection-setup)
4. [Critical: Password Session Sync](#critical-password-session-sync)
5. [Connection Methods](#connection-methods)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

## Overview

When connecting to a newly created VM via Windows Remote Desktop (RDP), you must first establish a password-authenticated session to properly sync credentials. SSH key-only connections will fail until this initial password sync is completed.

### Why Password Sync is Required

- **First-time authentication**: New VMs need initial password validation
- **Credential sync**: RDP uses different authentication than SSH keys
- **Session establishment**: Password login creates necessary user session data
- **Security handshake**: Establishes trust between client and server

## Prerequisites

### On the VM (Linux)

1. **Remote Desktop Server** (xrdp):
   ```bash
   sudo apt update
   sudo apt install xrdp -y
   sudo systemctl enable xrdp
   sudo systemctl start xrdp
   ```

2. **Desktop Environment** (if not installed):
   ```bash
   # For Ubuntu/Debian (XFCE - lightweight)
   sudo apt install xfce4 xfce4-goodies -y

   # Or GNOME (heavier)
   sudo apt install ubuntu-desktop -y

   # Or MATE (balanced)
   sudo apt install ubuntu-mate-desktop -y
   ```

3. **User Account with Password**:
   ```bash
   # Set password for your user
   sudo passwd your_username
   ```

4. **Firewall Configuration**:
   ```bash
   # Allow RDP port (3389)
   sudo ufw allow 3389/tcp
   sudo ufw reload
   ```

### On Windows Client

1. **Remote Desktop Connection** (built-in):
   - Press `Win + R`
   - Type: `mstsc`
   - Or search: "Remote Desktop Connection"

2. **VM Network Access**:
   - VM must be accessible on the network
   - Note the VM's IP address (e.g., `192.168.11.196`)

## Initial Connection Setup

### Step 1: First Connection (MUST use password)

**⚠️ CRITICAL: The first connection MUST use password authentication!**

1. Open Remote Desktop Connection (`mstsc`)

2. Enter connection details:
   - **Computer**: `192.168.11.196` (your VM IP)
   - **User name**: `mombe090` (your username)

3. Click **Connect**

4. When prompted for credentials:
   - **Username**: `mombe090`
   - **Password**: [your user password]
   - ✅ **Check**: "Remember me" (optional)

5. Accept the certificate warning (if prompted)

6. Wait for session to establish and desktop to load

### Step 2: Verify Session Sync

After the first password-authenticated connection:

```bash
# On the VM, verify the session
who
w
loginctl list-sessions
```

You should see your RDP session listed.

### Step 3: Test SSH Access

Now SSH key authentication should work:

```bash
# From your local machine
ssh mombe090@192.168.11.196

# Should connect without password prompt (using SSH key)
```

## Critical: Password Session Sync

### ❌ What Happens if You Skip Password Login

If you try to connect with SSH keys before doing password RDP login:

```bash
ssh mombe090@192.168.11.196
# ❌ Permission denied (publickey)
# or
# ❌ Connection times out
# or
# ❌ Authentication failed
```

**RDP Connection will also fail:**
- Blank screen
- Immediate disconnect
- "Session terminated" errors
- Authentication loops

### ✅ Correct Sequence

1. **First**: RDP with password → Session syncs
2. **Then**: SSH with keys → Works perfectly
3. **After**: RDP can use saved credentials or keys

### Why This Matters

The password RDP session:
- Creates user profile on the RDP server
- Initializes session databases
- Syncs credentials across authentication systems
- Establishes user context for future connections

**Without this sync, the system doesn't "know" your user for RDP purposes.**

## Connection Methods

### Method 1: Windows Remote Desktop (GUI)

**Using Remote Desktop Connection:**

1. Press `Win + R`, type `mstsc`, Enter

2. Click "Show Options" for advanced settings:
   - **General Tab**:
     - Computer: `192.168.11.196`
     - User name: `mombe090`
     - ✅ Allow me to save credentials

   - **Display Tab**:
     - Resolution: Full screen or custom
     - Colors: True Color (32 bit)

   - **Local Resources Tab**:
     - ✅ Printers
     - ✅ Clipboard
     - ✅ Drives (if needed)

   - **Experience Tab**:
     - Connection speed: LAN (10 Mbps or higher)
     - ✅ Desktop background
     - ✅ Font smoothing

   - **Advanced Tab**:
     - Server authentication: Warn me

3. Click **Connect**

4. Enter password when prompted

5. Desktop loads → Connection successful ✅

### Method 2: Command Line RDP

**Using mstsc command:**

```cmd
REM Basic connection
mstsc /v:192.168.11.196

REM Full screen
mstsc /v:192.168.11.196 /f

REM With username
mstsc /v:192.168.11.196 /u:mombe090

REM Load saved connection
mstsc connection.rdp
```

### Method 3: PowerShell RDP

**Using PowerShell:**

```powershell
# Basic RDP connection
cmdkey /generic:192.168.11.196 /user:mombe090 /pass:YourPassword
mstsc /v:192.168.11.196

# Remove saved credentials after
cmdkey /delete:192.168.11.196
```

### Method 4: Saved Connection File

Create `vm-connection.rdp`:

```ini
screen mode id:i:2
use multimon:i:0
desktopwidth:i:1920
desktopheight:i:1080
session bpp:i:32
winposstr:s:0,3,0,0,800,600
compression:i:1
keyboardhook:i:2
audiocapturemode:i:0
videoplaybackmode:i:1
connection type:i:7
networkautodetect:i:1
bandwidthautodetect:i:1
displayconnectionbar:i:1
enableworkspacereconnect:i:0
disable wallpaper:i:0
allow font smoothing:i:0
allow desktop composition:i:0
disable full window drag:i:1
disable menu anims:i:1
disable themes:i:0
disable cursor setting:i:0
bitmapcachepersistenable:i:1
full address:s:192.168.11.196
audiomode:i:0
redirectprinters:i:1
redirectcomports:i:0
redirectsmartcards:i:1
redirectclipboard:i:1
redirectposdevices:i:0
autoreconnection enabled:i:1
authentication level:i:2
prompt for credentials:i:0
negotiate security layer:i:1
remoteapplicationmode:i:0
alternate shell:s:
shell working directory:s:
gatewayhostname:s:
gatewayusagemethod:i:4
gatewaycredentialssource:i:4
gatewayprofileusagemethod:i:0
promptcredentialonce:i:0
gatewaybrokeringtype:i:0
use redirection server name:i:0
rdgiskdcproxy:i:0
kdcproxyname:s:
username:s:mombe090
```

Double-click to connect.

## Troubleshooting

### Issue 1: "Connection Failed" or "Unable to Connect"

**Symptoms:**
- Can't reach the VM
- Connection timeout

**Solutions:**

1. **Verify VM is running:**
   ```bash
   # From another terminal
   ping 192.168.11.196
   ```

2. **Check xrdp service:**
   ```bash
   ssh mombe090@192.168.11.196
   sudo systemctl status xrdp
   sudo systemctl restart xrdp
   ```

3. **Check firewall:**
   ```bash
   sudo ufw status
   sudo ufw allow 3389/tcp
   ```

4. **Verify port is listening:**
   ```bash
   sudo netstat -tlnp | grep 3389
   # Should show xrdp listening
   ```

### Issue 2: "Session Terminated" or Blank Screen

**Symptoms:**
- Connects briefly then disconnects
- Blank/black screen
- Immediate logout

**Solutions:**

1. **✅ USE PASSWORD on first connection** (most common fix)

2. **Check desktop environment:**
   ```bash
   ssh mombe090@192.168.11.196
   echo "xfce4-session" > ~/.xsession
   # or
   echo "gnome-session" > ~/.xsession
   ```

3. **Verify xrdp configuration:**
   ```bash
   sudo nano /etc/xrdp/startwm.sh

   # Add before "test -x" line:
   unset DBUS_SESSION_BUS_ADDRESS
   unset XDG_RUNTIME_DIR
   ```

4. **Check logs:**
   ```bash
   tail -f /var/log/xrdp.log
   tail -f /var/log/xrdp-sesman.log
   ```

### Issue 3: "Authentication Failed" Loop

**Symptoms:**
- Credentials rejected repeatedly
- "Wrong password" even with correct password

**Solutions:**

1. **Reset password on VM:**
   ```bash
   ssh mombe090@192.168.11.196
   sudo passwd mombe090
   # Enter new password twice
   ```

2. **Clear saved credentials on Windows:**
   ```cmd
   cmdkey /list
   cmdkey /delete:192.168.11.196
   ```

3. **Check user account:**
   ```bash
   id mombe090
   # Verify user exists and groups
   ```

### Issue 4: SSH Works but RDP Doesn't

**Symptoms:**
- SSH key authentication works fine
- RDP fails or hangs

**Solution:**

**THIS IS THE PASSWORD SYNC ISSUE!**

1. **You MUST reconnect with password:**
   - Open RDP client
   - Enter IP: `192.168.11.196`
   - Enter username: `mombe090`
   - **Enter PASSWORD** (not SSH key)
   - Connect and let desktop load fully

2. **After password session establishes:**
   - SSH will continue to work
   - RDP will work with or without saved credentials

### Issue 5: Slow or Laggy Connection

**Solutions:**

1. **Reduce display quality:**
   - Lower resolution
   - Reduce color depth to 16-bit
   - Disable desktop background
   - Disable font smoothing

2. **Disable features:**
   - Uncheck "Desktop composition"
   - Uncheck "Show window contents while dragging"
   - Uncheck "Menu animations"

3. **Network optimization:**
   ```bash
   # On VM, edit xrdp.ini
   sudo nano /etc/xrdp/xrdp.ini

   # Set:
   crypt_level=low
   bulk_compression=true
   ```

### Issue 6: Clipboard Not Working

**Solutions:**

1. **Install clipboard support:**
   ```bash
   sudo apt install xrdp-pulseaudio-installer -y
   ```

2. **Restart xrdp:**
   ```bash
   sudo systemctl restart xrdp
   ```

3. **In RDP client:**
   - Local Resources → More
   - ✅ Enable Clipboard

## Best Practices

### 1. Initial Setup Checklist

- [ ] Create VM with desktop environment
- [ ] Install and enable xrdp
- [ ] Set user password
- [ ] Configure firewall (allow 3389)
- [ ] **FIRST CONNECTION: Use password RDP**
- [ ] Verify session establishes
- [ ] Test SSH access afterward
- [ ] Save RDP connection file

### 2. Security Recommendations

**Change default RDP port:**
```bash
sudo nano /etc/xrdp/xrdp.ini
# Change: port=3389 to port=13389

sudo systemctl restart xrdp
sudo ufw allow 13389/tcp
sudo ufw delete allow 3389/tcp
```

**Use SSH tunnel for RDP:**
```bash
# On Windows (PowerShell)
ssh -L 3389:localhost:3389 mombe090@192.168.11.196

# Then RDP to: localhost
```

**Limit RDP access:**
```bash
sudo ufw allow from 192.168.11.0/24 to any port 3389
```

### 3. Connection Workflow

**Recommended order for new VM:**

```
1. Create VM
2. Install OS + Desktop Environment
3. Install xrdp
4. Set password: sudo passwd username
5. Configure firewall
6. First RDP connection WITH PASSWORD ← CRITICAL
7. Let desktop fully load
8. Disconnect
9. Now SSH will work
10. Future RDP connections can use saved credentials
```

### 4. Multiple Monitors

**Enable multiple monitors:**

1. In RDP client:
   - Display tab
   - ✅ Use all my monitors
   - Or set custom resolution

2. Edit `.rdp` file:
   ```ini
   use multimon:i:1
   ```

### 5. Performance Tuning

**For better performance:**

```bash
# Use XFCE (lightweight) instead of GNOME
sudo apt install xfce4 xfce4-goodies

# Disable compositing
xfconf-query -c xfwm4 -p /general/use_compositing -s false

# Reduce visual effects
xfconf-query -c xfwm4 -p /general/theme -s Default
```

## Quick Reference

### Common Commands

```bash
# Check xrdp status
sudo systemctl status xrdp

# Restart xrdp
sudo systemctl restart xrdp

# View active sessions
who
w

# Check RDP logs
tail -f /var/log/xrdp.log

# Reset password
sudo passwd username

# Allow RDP through firewall
sudo ufw allow 3389/tcp
```

### RDP Connection Strings

```cmd
REM Basic
mstsc /v:192.168.11.196

REM Fullscreen
mstsc /v:192.168.11.196 /f

REM Admin mode
mstsc /v:192.168.11.196 /admin

REM With width/height
mstsc /v:192.168.11.196 /w:1920 /h:1080
```

## Summary

**KEY TAKEAWAY:**

🔑 **ALWAYS use password authentication for the first RDP connection to a new VM.**

This syncs the session and enables all other authentication methods (SSH keys, saved credentials, etc.) to work properly afterward.

**Steps:**
1. ✅ First RDP → Use password
2. ✅ Session syncs
3. ✅ SSH keys work
4. ✅ Future RDP works with any method

**Skip password sync → Nothing works! 🚫**

## Additional Resources

- [xrdp Official Documentation](http://xrdp.org/)
- [Microsoft RDP Documentation](https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/remote-desktop-clients)
- [Ubuntu RDP Guide](https://ubuntu.com/tutorials/ubuntu-desktop-remote-desktop)

---

**Last Updated:** January 31, 2026
**Tested With:** Ubuntu 22.04/24.04, Windows 11, xrdp 0.9.x
