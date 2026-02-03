# Client Scanner Distribution Guide

## ⚠️ Important: FiveM Cannot Auto-Install .exe Files

**FiveM servers CANNOT automatically install executable files on players' computers for security reasons.**

However, your anti-cheat now has automatic download prompts configured!

## ✅ What's Now Configured:

### 1. **Automatic Download Prompts** ✨
- When players join, they see a download link in chat
- Periodic reminders every 5 minutes (if not running scanner)
- In-game notifications about enhanced protection

### 2. **Server-Side Detection (Works Without Client Scanner)**
Your anti-cheat now works in **two modes**:

**Mode 1: Server-Only (Current)**
- Detects Blum Panel through resource injection
- Blocks panel commands (`/blum`, `/cipher`, etc.)
- Monitors suspicious events and patterns
- Checks for backdoor resources

**Mode 2: Server + Client Scanner (Enhanced)**
- All server-side detections PLUS
- Process detection (catches running cheat programs)
- Additional memory/DLL injection checks

## 📥 How to Distribute Client Scanner:

### Option 1: Discord (Recommended - Easiest)
1. Build the scanner:
   ```
   cd client-scanner
   dotnet publish -c Release -r win-x64 --self-contained
   ```
2. The file is in: `bin\Release\net8.0-windows\win-x64\publish\ClientScanner.exe`
3. Upload to your Discord server
4. Right-click → Copy Link
5. Update config.lua:
   ```lua
   Config.ClientScannerUrl = "https://cdn.discordapp.com/attachments/YOUR_LINK_HERE"
   ```

### Option 2: GitHub Releases
1. Create a GitHub repository
2. Create a new Release
3. Upload `ClientScanner.exe` as an asset
4. Copy the download link
5. Update config.lua with the link

### Option 3: Google Drive / Dropbox
1. Upload ClientScanner.exe
2. Get shareable link (make sure it's public)
3. Update config.lua

### Option 4: Your Own Website
1. Upload to your hosting
2. Use direct download link (e.g., `https://yoursite.com/downloads/ClientScanner.exe`)

## 🎮 Player Experience:

**When player joins WITHOUT scanner:**
```
================================
Enhanced Protection Available!
Download ClientScanner for extra security:
https://your-download-link.com
================================

💡 Tip: Run ClientScanner.exe for better protection
```

**When player joins WITH scanner:**
- No prompts shown
- Silent protection in background

## ⚙️ Configuration Options:

### Current Settings (Recommended):
```lua
Config.RequireClientScanner = false      -- Don't force (optional)
Config.RecommendClientScanner = true     -- Show prompts
Config.ShowDownloadPrompt = true         -- Show on join
Config.DownloadPromptInterval = 300      -- Remind every 5 min
```

### To Make Scanner MANDATORY:
```lua
Config.RequireClientScanner = true       -- Kick if not running
Config.RecommendClientScanner = false    -- Don't need warnings if forcing
```

### To Disable Prompts:
```lua
Config.RequireClientScanner = false
Config.RecommendClientScanner = false
Config.ShowDownloadPrompt = false
```

## 📊 Detection Coverage:

| Cheat Type | Server-Only | Server + Scanner |
|------------|-------------|------------------|
| Blum Panel Resources | ✅ | ✅ |
| Panel Commands | ✅ | ✅ |
| Suspicious Events | ✅ | ✅ |
| Running Processes | ❌ | ✅ |
| Memory Injection | ⚠️ Partial | ✅ |

## 🔧 Current Protection Status:

✅ **Blum Panel Detection** - Fully Active (Server-Side)
✅ **Command Blocking** - Active
✅ **Resource Monitoring** - Active
✅ **Event Pattern Detection** - Active
✅ **Download Prompts** - Configured

⚠️ **Process Detection** - Requires client scanner (optional)

## 💡 Recommendation:

**Start with current setup (RecommendClientScanner = true)**
- Players can play without scanner
- Server-side detection catches most cheats
- Download prompts encourage scanner usage
- After 1-2 weeks, if >60% compliance, consider making it mandatory

## 🚀 Next Steps:

1. **Upload ClientScanner.exe** to Discord/GitHub/Website
2. **Copy the download link**
3. **Update config.lua** with your link:
   ```lua
   Config.ClientScannerUrl = "YOUR_ACTUAL_DOWNLOAD_LINK_HERE"
   ```
4. **Restart server**: `restart SLES-anticheat`
5. **Test**: Join server and verify prompt appears

## ❓ FAQ:

**Q: Can I force auto-install?**
A: No, FiveM and Windows security prevent this.

**Q: Will anti-cheat work without client scanner?**
A: Yes! Server-side detection is fully functional.

**Q: How many players need the scanner?**
A: It's optional. More coverage = better protection.

**Q: What if player deletes scanner?**
A: They'll see download prompts again. No penalty unless you set RequireClientScanner = true.
