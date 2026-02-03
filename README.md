# FiveM Anti-Cheat Resource

## Installation via FiveM Panel

### Step 1: Download the Resource

1. **Download this folder** (`fivem-resource`) to your local computer
2. **Rename** the folder to just `anticheat`

### Step 2: Upload via Panel

#### txAdmin Panel:
1. Login to your txAdmin panel
2. Go to **Server** → **Resources**
3. Click **Upload Resource** or **File Manager**
4. Navigate to `resources/` folder
5. Upload the `SLES-anticheat` folder
6. Restart your server or use: `ensure SLES-anticheat`

#### Pterodactyl Panel:
1. Login to your Pterodactyl panel
2. Go to **File Manager**
3. Navigate to: `resources/` or `server-data/resources/`
4. Click **Upload** button
5. Upload the entire `anticheat` folder (as a ZIP)
6. Extract if needed
7. Restart server

#### Other Hosting Panels (ZAP, Iceline, etc):
1. Login to your control panel
2. Find **File Manager** or **FTP Access**
3. Navigate to `resources/` folder
4. Upload `anticheat` folder
5. Restart server

### Step 3: Enable in server.cfg

Add to your `server.cfg`:

```cfg
# Anti-Cheat System
ensure anticheat
```

### Step 4: Configure (Optional)

Edit `config.lua` to customize:

```lua
Config.AutoBan = true          -- Automatically ban detected cheaters
Config.EnableWebhook = false   -- Set to true and add Discord webhook
Config.WebhookURL = ""         -- Your Discord webhook URL
```

## Features

✅ **Speed Hack Detection** - Detects impossible movement speeds  
✅ **Teleport Detection** - Catches instant position changes  
✅ **God Mode Detection** - Identifies invincibility cheats  
✅ **Weapon Spawn Detection** - Blocks unauthorized weapons  
✅ **Resource Injection Blocking** - Prevents cheat menu resources  
✅ **Protected Event Blocking** - Stops exploit triggers  
✅ **Explosion Detection** - Blocks mod menu explosions  
✅ **No-Clip Detection** - Catches flying/wall hacking  
✅ **Ban System** - Automatic ban database  

## Admin Commands

```
/acban <id> <reason>   - Ban a player
/acunban <identifier>  - Unban a player
/acstats               - View anti-cheat stats
```

## Configuration

### Enable Discord Webhooks

1. Create a Discord webhook in your server
2. Copy the webhook URL
3. Edit `config.lua`:
```lua
Config.EnableWebhook = true
Config.WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
```

### Adjust Detection Sensitivity

Edit thresholds in `config.lua`:
```lua
Config.MaxSpeed = 150.0              -- Lower = stricter
Config.MaxTeleportDistance = 100.0   -- Lower = stricter  
Config.CheckInterval = 5000          -- Lower = more frequent checks
```

### Behavioral/Aimbot/ESP Heuristics
Tune these in `config.lua` (server‑side heuristics):
```lua
Config.EnableBehavioralDetection = true
Config.AimbotMinShots = 50
Config.AimbotHeadshotRatioThreshold = 70
Config.AimbotSuspicionCount = 5
Config.AimbotConsecutiveHeadshots = 8
Config.AimbotConsecutiveWindowMs = 2000
Config.ESPLongDistanceThreshold = 120.0
Config.ESPLongDistanceHeadshots = 6
Config.RapidFireMinIntervalMs = 60
Config.RapidFireViolations = 25
Config.AimSnapDeltaThreshold = 35
Config.AimSnapIntervalMs = 50
Config.AimSnapViolations = 3
Config.AimSnapWindowMs = 4000
Config.AimSnapCooldownMs = 3000
Config.AimSnapShotWindowMs = 120
Config.AimAccelThresholdDegPerSec2 = 1800
Config.AimAccelViolations = 3
Config.AimAccelWindowMs = 4000
Config.AimAccelCooldownMs = 3000
Config.AverageTTKMs = 900
Config.BehavioralCooldownTTKMultiplier = 2
```

### Average TTK Tracker
Enable server-side tracking of average time-to-kill:
```lua
Config.EnableTTKTracker = true
Config.TTKSampleSize = 100
```
The server console will print rolling average TTK once the sample size is reached.

### Whitelist Weapons

Add allowed weapons to `config.lua`:
```lua
Config.WhitelistedWeapons = {
    "WEAPON_PISTOL",
    "WEAPON_NIGHTSTICK",
    "WEAPON_STUNGUN",
    -- Add your job weapons here
}
```

## Ban Management

Bans are stored in: `resources/SLES-anticheat/bans.json`

You can manually edit this file to manage bans.

## Testing

1. Start your server with `ensure anticheat`
2. Join your server
3. Check server console for: `[ANTI-CHEAT] Server-side anti-cheat loaded`
4. Try triggering a protected event (it should be blocked)

## Compatibility

✅ Works with ESX/QBCore/Standalone  
✅ Works with txAdmin, Pterodactyl, ZAP-Hosting  
✅ No dependencies required  
✅ Lightweight (minimal performance impact)

## Limitations

⚠️ **Important limitations:**
- This is **not** a kernel-level anti-cheat. Advanced private menus and external ESP can still bypass detection.
- Client scanning depends on players running the **ClientScanner.exe** (can be bypassed by skilled attackers).
- Behavioral detections are **heuristics** and can produce false positives if tuned too aggressively.
- Screenshot checks require `screenshot-basic` and Discord webhook limits apply.

✅ **Strong coverage (when configured correctly):**
- Speed hacks, teleport, god mode
- Weapon/vehicle spawning
- No-clip/fly patterns
- Rapid fire, aim‑snap patterns, long‑range headshots
- Suspicious explosions and resource injection attempts

## Support

Check server console for detection logs:
```
[ANTI-CHEAT] Detection - Player: PlayerName | Type: SpeedHack | Details: Speed: 250.00
```

## Updating

1. Stop the server
2. Replace the `anticheat` folder
3. Start the server
4. Your bans will be preserved in `bans.json`

## Documentation

All guides are in the `docs/` folder:
- `docs/CLIENT_SCANNER_SETUP.md`
- `docs/CLIENT_DISTRIBUTION_GUIDE.md`
- `docs/INSTALLATION_CHECKLIST.md`
- `docs/QUICK_REFERENCE.md`
- `docs/UPDATE_SUMMARY.md`
- `docs/BACKDOOR_CIPHER_PROTECTION.md`
- `docs/ENHANCED_BACKDOOR_BLOCKING.md`
- `docs/BACKDOOR_ENHANCEMENT_SUMMARY.md`
- `docs/README_SERVERSIDE_ONLY.md`
- `docs/LOGO_SETUP.md`
- `docs/COMPLETE_FEATURES.md`

## WPF Dashboard (Optional)

The `wpf-client` folder contains a Windows dashboard app.

**Setup:**
1. Set `Config.EnableDashboardEndpoint = true` in `config.lua`.
2. (Optional) Set `Config.DashboardApiKey` and put the same value in `wpf-client/appsettings.json`.
3. Build and run the app:
    - Open `wpf-client/WpfClient.csproj` in Visual Studio
    - Run (F5)

The app reads from: `http://127.0.0.1:30120/anticheat/detections` by default.

## Syncing Edits Between Office & Home

Use Git so both PCs stay in sync:

1. **Office PC**
    - Pull latest: `git pull`
    - Make edits
    - Commit: `git add .` then `git commit -m "your message"`
    - Push: `git push`

2. **Home PC**
    - Pull latest: `git pull`
    - Make edits
    - Commit + push the same way

**Tip:** Always pull before you start editing on another PC.
