# SERVER-SIDE ONLY ANTI-CHEAT# SERVER-SIDE ONLY ANTI-CHEAT













































































































































































































































































































It won't catch Cheat Engine sitting idle on their PC, but it WILL catch them the moment they actually use it to exploit your server. 🛡️**This is the BEST you can do without client-side installation!**---```6. Test ban commands5. Verify Discord webhooks work4. Check server console for detections3. Try speed hacks2. Try spawning a vehicle via mod menu (if testing)1. Join your server```## Testing:---- [ ] Monitor logs for first few days- [ ] Test with /acstats command- [ ] Restart server- [ ] Whitelist admin ACE permissions- [ ] Add Discord webhook (optional)- [ ] Configure `config.lua` (optional)- [ ] Add `ensure anticheat` to server.cfg- [ ] Upload `anticheat` folder to server## Quick Setup Checklist:---**BUT:** Even sophisticated cheats will trigger behavioral detection when they actually use exploits!- Client-side modifications (texture mods, etc.)- Cheat Engine if used very carefully- Subtle ESP (you can't see what they see)- Very sophisticated private cheats### What You Might Miss:- Resource injections / exploits- Obvious aimbots / triggerbots- Most god mode / teleport exploits- 90%+ of casual cheaters (menu users, speedhackers)### What You'll Catch:## Realistic Expectations:---6. **Server-side validation** - Always validate transactions server-side5. **Use trusted frameworks** - ESX/QBCore have built-in protections4. **Combine with manual moderation** - No AC is perfect3. **Review bans weekly** - Check for false positives2. **Whitelist admins** - Prevent false admin bans1. **Enable Discord webhooks** - Review all detections## Best Practices:---- Review ban logs regularly- Whitelist admins: `add_ace group.admin anticheat.bypass allow`- Require multiple violations before ban**Workaround:**### Limitation: False positives can occur- Review unusual players manually- Combine with manual admin oversight- Use statistical analysis (aimbot headshot ratios, etc.)**Workaround:**### Limitation: Advanced private menus may bypass- Even if they use Cheat Engine, when they exploit, you'll catch it- Focus on detecting what they DO with it (speed, teleport, etc.)**Workaround:**### Limitation: Cannot detect Cheat Engine## Limitations & Workarounds:---```/acstats                 - View anti-cheat statistics/acunban [identifier]    - Unban player/acban [id] [reason]     - Manually ban player```## Admin Commands:---```Action: Auto-bannedDetails: Speed: 250.00 (Violations: 5)Type: SpeedHackPlayer: John_Doe🚨 Cheat Detected```You'll receive:```Config.WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"Config.EnableWebhook = true```luaGet notified when players cheat:## Discord Webhook Alerts:---```Config.CheckInterval = 10000Config.MaxTeleportDistance = 150.0Config.MaxSpeed = 200.0```lua**Lenient Mode (fewer false positives, may miss some):**```Config.CheckInterval = 5000Config.MaxTeleportDistance = 100.0Config.MaxSpeed = 150.0```lua**Balanced Mode (recommended):**```Config.CheckInterval = 3000          -- Check every 3sConfig.MaxTeleportDistance = 50.0    -- StrictConfig.MaxSpeed = 120.0              -- Lower threshold```lua**Strict Mode (more detections, some false positives):**### Adjust Sensitivity:## Configuration:---```- Invincibility flags- Health > max health- No damage taken for extended periods-- Detects godmode```lua### 5. **Health/Damage Tracking**```- Prop spawning- Weapon spawning- Vehicle spam (>10 in 5 seconds)-- Monitors spawning```lua### 4. **Entity Tracking**```- Unauthorized commands- Protected server events- Money/item spawn events-- Blocks exploit triggers```lua### 3. **Event Monitoring**```- Perfect accuracy = Triggerbot- Firing rate < 50ms = Rapid fire- Headshot ratio > 70% = Aimbot-- Analyzes player behavior patterns```lua### 2. **Statistical Analysis**```- Walking through walls- Flying without vehicle- Teleport > 100m instantly- Speed > 150 units/s (on foot)-- Detects impossible physics violations```lua### 1. **Physics-Based Detection**## Detection Methods:---```                              └──────────────────┘                              │ → Discord Alert  │                              │ → Auto-Ban       │                              │ If suspicious:   │                              ┌────────▼─────────┐                                       │                              └──────────────────┘                              │ - Behavior       │                              │ - Stats          │                              │ - Weapons        │                              │ - Health         │                              │ - Position       │                              │ - Speed          │                              ┌────────▼─────────┐n                              │ Analyzes:        │                                       │└─────────────┘               └──────────────────┘│ (Gameplay)  │   Game Events │ (Anti-Cheat)     ││ FiveM       │◄─────────────►│ FiveM Resource   │┌─────────────┐               ┌──────────────────┐Player's PC                    Your Server```## How It Works:---**DONE!** No client installation needed.```Config.WebhookURL = "YOUR_DISCORD_WEBHOOK"Config.EnableWebhook = trueConfig.AutoBan = true```luaEdit `config.lua`:### Step 4: Configure (Optional)```restart your-server# Via txAdmin, panel, or console```bash### Step 3: Restart Server```ensure anticheat# Add this line```cfg### Step 2: Enable in server.cfg```3. Rename folder to: anticheat2. Place in: server-data/resources/1. Upload 'fivem-resource' folder to your server```Via **FTP/Panel/SSH**:### Step 1: Upload to Your Server## Installation (NO Player Action Required!):---**Why?** FiveM runs in a sandbox and cannot access Windows processes or system memory on the player's PC.- Memory modifications on player's PC- Client-side processes/windows- Process Hacker, x64dbg, debuggers- Eulen, RedEngine, or other executables- DLL injections on player's PC- Cheat Engine running on player's PC### ❌ **Cannot Detect (FiveM Limitations):**## What It CANNOT Detect:---- Unrealistic play patterns- Perfect accuracy- Impossible damage output### ✅ **Statistical Anomalies:**- Rapid entity spawning (vehicle spam, etc.)- Resource injection- Unauthorized event triggers- Item duplication- Money spawning### ✅ **Resource/Event Exploits:**- Inhuman reaction times- Triggerbot patterns- Rapid fire (shooting too fast)- Aimbot (headshot ratio >70%)### ✅ **Behavioral Analysis:**- Vehicle modifications (super speed, etc.)- Invisibility- Super jump- No-clip / Flying- God mode / Invincibility- Teleportation- Speed hacks (inhuman movement)### ✅ **In-Game Exploits:**## What It CAN Detect (Server-Side Only):---Since you cannot install software on players' PCs, this is a **pure FiveM resource** approach.## Maximum Protection WITHOUT Client Installation## Maximum Protection WITHOUT Client Installation

Since you cannot install software on players' PCs, this is a **pure FiveM resource** approach.

---

## What It CAN Detect (Server-Side Only):

### ✅ **In-Game Exploits:**
- Speed hacks (inhuman movement)
- Teleportation
- God mode / Invincibility
- No-clip / Flying
- Super jump
- Invisibility
- Vehicle modifications (super speed, etc.)

### ✅ **Behavioral Analysis:**
- Aimbot (headshot ratio >70%)
- Rapid fire (shooting too fast)
- Triggerbot patterns
- Inhuman reaction times

### ✅ **Resource/Event Exploits:**
- Money spawning
- Item duplication
- Unauthorized event triggers
- Resource injection
- Rapid entity spawning (vehicle spam, etc.)

### ✅ **Statistical Anomalies:**
- Impossible damage output
- Perfect accuracy
- Unrealistic play patterns

---

## What It CANNOT Detect:

### ❌ **Cannot Detect (FiveM Limitations):**
- Cheat Engine running on player's PC
- DLL injections on player's PC
- Eulen, RedEngine, or other executables
- Process Hacker, x64dbg, debuggers
- Client-side processes/windows
- Memory modifications on player's PC

**Why?** FiveM runs in a sandbox and cannot access Windows processes or system memory on the player's PC.

---

## Installation (NO Player Action Required!):

### Step 1: Upload to Your Server

Via **FTP/Panel/SSH**:
```
1. Upload 'fivem-resource' folder to your server
2. Place in: server-data/resources/
3. Rename folder to: anticheat
```

### Step 2: Enable in server.cfg

```cfg
# Add this line
ensure anticheat
```

### Step 3: Restart Server

```bash
# Via txAdmin, panel, or console
restart your-server
```

### Step 4: Configure (Optional)

Edit `config.lua`:
```lua
Config.AutoBan = true
Config.EnableWebhook = true
Config.WebhookURL = "YOUR_DISCORD_WEBHOOK"
```

**DONE!** No client installation needed.

---

## How It Works:

```
Player's PC                    Your Server
┌─────────────┐               ┌──────────────────┐
│ FiveM       │◄─────────────►│ FiveM Resource   │
│ (Gameplay)  │   Game Events │ (Anti-Cheat)     │
└─────────────┘               └──────────────────┘
                                       │
                              ┌────────▼─────────┐
                              │ Analyzes:        │
                              │ - Speed          │
                              │ - Position       │
                              │ - Health         │
                              │ - Weapons        │
                              │ - Stats          │
                              │ - Behavior       │
                              └──────────────────┘
                                       │
                              ┌────────▼─────────┐
                              │ If suspicious:   │
                              │ → Auto-Ban       │
                              │ → Discord Alert  │
                              └──────────────────┘
```

---

## Detection Methods:

### 1. **Physics-Based Detection**
```lua
-- Detects impossible physics violations
- Speed > 150 units/s (on foot)
- Teleport > 100m instantly
- Flying without vehicle
- Walking through walls
```

### 2. **Statistical Analysis**
```lua
-- Analyzes player behavior patterns
- Headshot ratio > 70% = Aimbot
- Firing rate < 50ms = Rapid fire
- Perfect accuracy = Triggerbot
```

### 3. **Event Monitoring**
```lua
-- Blocks exploit triggers
- Money/item spawn events
- Protected server events
- Unauthorized commands
```

### 4. **Entity Tracking**
```lua
-- Monitors spawning
- Vehicle spam (>10 in 5 seconds)
- Weapon spawning
- Prop spawning
```

### 5. **Health/Damage Tracking**
```lua
-- Detects godmode
- No damage taken for extended periods
- Health > max health
- Invincibility flags
```

---

## Configuration:

### Adjust Sensitivity:

**Strict Mode (more detections, some false positives):**
```lua
Config.MaxSpeed = 120.0              -- Lower threshold
Config.MaxTeleportDistance = 50.0    -- Strict
Config.CheckInterval = 3000          -- Check every 3s
```

**Balanced Mode (recommended):**
```lua
Config.MaxSpeed = 150.0
Config.MaxTeleportDistance = 100.0
Config.CheckInterval = 5000
```

**Lenient Mode (fewer false positives, may miss some):**
```lua
Config.MaxSpeed = 200.0
Config.MaxTeleportDistance = 150.0
Config.CheckInterval = 10000
```

---

## Discord Webhook Alerts:

Get notified when players cheat:

```lua
Config.EnableWebhook = true
Config.WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
```

You'll receive:
```
🚨 Cheat Detected
Player: John_Doe
Type: SpeedHack
Details: Speed: 250.00 (Violations: 5)
Action: Auto-banned
```

---

## Admin Commands:

```
/acban [id] [reason]     - Manually ban player
/acunban [identifier]    - Unban player
/acstats                 - View anti-cheat statistics
```

---

## Limitations & Workarounds:

### Limitation: Cannot detect Cheat Engine

**Workaround:**
- Focus on detecting what they DO with it (speed, teleport, etc.)
- Even if they use Cheat Engine, when they exploit, you'll catch it

### Limitation: Advanced private menus may bypass

**Workaround:**
- Use statistical analysis (aimbot headshot ratios, etc.)
- Combine with manual admin oversight
- Review unusual players manually

### Limitation: False positives can occur

**Workaround:**
- Require multiple violations before ban
- Whitelist admins: `add_ace group.admin anticheat.bypass allow`
- Review ban logs regularly

---

## Best Practices:

1. **Enable Discord webhooks** - Review all detections
2. **Whitelist admins** - Prevent false admin bans
3. **Review bans weekly** - Check for false positives
4. **Combine with manual moderation** - No AC is perfect
5. **Use trusted frameworks** - ESX/QBCore have built-in protections
6. **Server-side validation** - Always validate transactions server-side

---

## Realistic Expectations:

### What You'll Catch:
- 90%+ of casual cheaters (menu users, speedhackers)
- Most god mode / teleport exploits
- Obvious aimbots / triggerbots
- Resource injections / exploits

### What You Might Miss:
- Very sophisticated private cheats
- Subtle ESP (you can't see what they see)
- Cheat Engine if used very carefully
- Client-side modifications (texture mods, etc.)

**BUT:** Even sophisticated cheats will trigger behavioral detection when they actually use exploits!

---

## Quick Setup Checklist:

- [ ] Upload `anticheat` folder to server
- [ ] Add `ensure anticheat` to server.cfg
- [ ] Configure `config.lua` (optional)
- [ ] Add Discord webhook (optional)
- [ ] Whitelist admin ACE permissions
- [ ] Restart server
- [ ] Test with /acstats command
- [ ] Monitor logs for first few days

---

## Testing:

```
1. Join your server
2. Try spawning a vehicle via mod menu (if testing)
3. Try speed hacks
4. Check server console for detections
5. Verify Discord webhooks work
6. Test ban commands
```

---

**This is the BEST you can do without client-side installation!**

It won't catch Cheat Engine sitting idle on their PC, but it WILL catch them the moment they actually use it to exploit your server. 🛡️
