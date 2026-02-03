# Client Scanner Setup Guide

## What You Get (Option C - Both Scanner + Server-Side)

✅ **Server-side detections** (speed, teleport, godmode, aimbot, etc.) - **Always active**  
✅ **Client scanner** (Cheat Engine, mod menus, injectors) - **Optional but recommended**

## How It Works

### Scanner Features:
- Runs in Windows system tray (background)
- Scans for 20+ cheat tools every 5 seconds
- Sends heartbeat to server every 30 seconds
- Reports cheat detections instantly
- Players see it running (transparent, not hidden)

### Server Behavior (Based on Config):

**Mode 1: Recommended (Default)**
```lua
Config.RequireClientScanner = false
Config.RecommendClientScanner = true
```
- Players can join without scanner
- Server sends friendly reminder every minute if scanner not detected
- No kicks, just warnings
- Good for gradual rollout

**Mode 2: Mandatory**
```lua
Config.RequireClientScanner = true
Config.RecommendClientScanner = false
```
- Players MUST run scanner to stay connected
- Kicked after 2 minutes if no heartbeat detected
- Strict enforcement
- Best for competitive servers

**Mode 3: Disabled**
```lua
Config.RequireClientScanner = false
Config.RecommendClientScanner = false
```
- Pure server-side only
- No scanner requirement
- Fallback option

## Player Instructions

### To Build Scanner:
```bash
build-scanner.bat
```
Output: `client-scanner\bin\Release\net8.0-windows\win-x64\publish\ClientScanner.exe`

### Build Anywhere (GitHub Actions)
This repo now includes CI workflows that build the scanner on GitHub:
- **CI build artifact** on every push/PR to `client-scanner/`
- **Release build** when you push a tag like `v1.0.0`

**Release steps:**
1. Commit your changes
2. Create a tag: `v1.0.0`
3. Push the tag to GitHub
4. Download `ClientScanner.exe` from the GitHub Release assets

Update `Config.ClientScannerUrl` to your release asset URL, for example:
```
https://github.com/<your-user>/<your-repo>/releases/download/v1.0.0/ClientScanner.exe
```

### To Distribute:
1. Upload `ClientScanner.exe` to your website/Discord
2. Update `Config.ClientScannerUrl` in config.lua
3. Add to server rules: "ClientScanner recommended for best protection"

### Player Steps:
1. Download ClientScanner.exe
2. Right-click → Run as Administrator
3. See shield icon in system tray
4. Join server normally
5. Keep scanner running (minimized to tray)

## What Gets Detected

### Server-Side (Always):
- Speed hacks, teleport, godmode
- Aimbot, rapid fire, triggerbot
- Weapon/vehicle spawning
- Money/item exploits
- No-clip, super jump
- Entity spam

### Client Scanner (If Running):
- Cheat Engine (all versions)
- Eulen, Lynx, RedEngine
- Blum Panel, X-Menu, D-Panel
- Midnight, Nexus, Spectra
- Mod menus, executors, injectors
- 20+ known cheat tools

## Recommended Setup

**Week 1:** Set `RecommendClientScanner = true` (warnings only)  
**Week 2-3:** Monitor adoption rate via console logs  
**Week 4+:** If >70% compliance, optionally switch to `RequireClientScanner = true`

This gives players time to download and won't cause immediate disruption.
