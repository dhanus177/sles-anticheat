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

⚠️ **Cannot detect:**
- Cheat Engine running on player's PC (client-side processes)
- Advanced private menus with anti-detection
- External ESP tools

✅ **Can detect:**
- Speed hacks, teleport, god mode
- Weapon spawning, vehicle spawning
- No-clip, fly hacks
- Suspicious explosions
- Resource injection attempts

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
