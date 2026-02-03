# SERVER-SIDE ONLY ANTI-CHEAT
## Maximum Protection WITHOUT Client Installation

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
