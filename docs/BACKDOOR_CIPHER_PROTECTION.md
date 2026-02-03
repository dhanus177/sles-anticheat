# Anti-Backdoor & Anti-Cipher Panel System

## Overview
This anti-cheat system now includes comprehensive detection for backdoors and Cipher Panel, one of the most common FiveM cheat menus.

## Features Added

### 🛡️ Anti-Backdoor System
The backdoor detection system protects your server from unauthorized access and malicious resource injection.

#### Detection Methods:
1. **Resource Monitoring**
   - Scans all running resources on server start
   - Monitors new resource starts in real-time
   - Automatically stops suspicious/blacklisted resources
   - Pattern matching for backdoor indicators

2. **Protected Events**
   - Blocks client-side triggering of protected server events
   - Prevents ESX/QBCore money/item injection
   - Monitors admin command execution
   - Detects unauthorized database access

3. **SQL Injection Prevention**
   - Pattern detection for common SQL injection attempts
   - Monitors queries for malicious patterns
   - Automatic logging and banning

4. **File Access Protection**
   - Monitors access to sensitive files (server.cfg, database files)
   - Prevents unauthorized configuration changes
   - Alerts on suspicious file access patterns

#### Protected Events:
- `_cfx_internal`
- `esx:giveInventoryItem`
- `esx:giveMoney`
- `esx:setJob`
- `qb-banking:server:TransferMoney`
- `qb-inventory:server:AddItem`
- And many more...

### 🔴 Anti-Cipher Panel System
Cipher Panel is a popular cheat menu for FiveM. This system detects and prevents its usage.

#### Detection Methods:
1. **Resource Detection**
   - Scans for Cipher Panel resources
   - Blocks cipher-named resources
   - Monitors for runtime resource injection

2. **Event Monitoring**
   - Blocks known Cipher Panel events
   - Detects event spam (common Cipher Panel behavior)
   - Monitors NUI callbacks for suspicious patterns

3. **Command Blocking**
   - Blocks `/cipher`, `/cpanel`, `/ciphermenu` commands
   - Detects command execution attempts
   - Logs all blocked command attempts

4. **Behavioral Analysis**
   - Monitors for rapid event triggering
   - Detects abnormal network patterns
   - Checks for DLL injection signatures

5. **Memory Anomaly Detection**
   - Detects abnormal health/armor values
   - Monitors for unauthorized invincibility
   - Checks for suspicious player modifications

## Configuration

### In config.lua:
```lua
-- Enable/Disable Features
Config.EnableBackdoorCheck = true
Config.EnableCipherPanelDetection = true

-- Blacklisted Resources (includes Cipher Panel)
Config.BlacklistedResources = {
    "Cipher Panel",
    "CipherPanel",
    "Cipher Menu",
    "Backdoor",
    -- ... more
}
```

## Files Added

### Server-Side:
- `server/backdoor_detection.lua` - Main backdoor detection logic
- `server/cipher_panel_detection.lua` - Cipher Panel specific detection

### Client-Side:
- `client/cipher_backdoor_check.lua` - Client-side monitoring and detection

### Shared:
- Updated `shared/cheat_database.lua` with Cipher Panel signatures

## How It Works

### Backdoor Detection Flow:
1. Server starts → Scans all active resources
2. New resource starts → Pattern matching check
3. Protected event triggered → Immediate ban
4. Admin command executed → Permission check
5. Suspicious activity → Discord webhook alert

### Cipher Panel Detection Flow:
1. Client monitors for suspicious resources
2. Server blocks known Cipher Panel events
3. Command execution → Blocked and logged
4. Event spam detected → Player flagged
5. Multiple violations → Automatic ban

## Alerts & Logging

All detections are logged with:
- Player name and identifier
- Detection type and method
- Timestamp
- Additional context

Discord webhooks (if enabled) send:
- 🚨 Resource detections
- 🔒 Protected event triggers
- ⚠️ Unauthorized commands
- 🔴 Cipher Panel activity
- 💉 SQL injection attempts

## Ban Reasons

Players will be banned for:
- `Backdoor Attempt` - Unauthorized access attempt
- `Backdoor Exploit` - Triggering protected events
- `Cipher Panel` - Using Cipher Panel cheat
- `Cipher Panel Command` - Executing cipher commands
- `Event Spam` - Rapid event triggering (Cipher behavior)
- `SQL Injection` - Database attack attempt
- `Unauthorized File Access` - Accessing protected files

## Testing

To test the system:
1. Start a resource with "cipher" in the name → Should be blocked
2. Try command `/cipher` → Should be blocked
3. Trigger a protected event from client → Should ban

## Performance

- Resource scanning: One-time on start + minimal monitoring
- Event handlers: Negligible performance impact
- Client-side checks: 5-20 second intervals
- Server-side checks: Real-time event-based

## Compatibility

Works with:
- ESX Framework
- QBCore Framework
- Standalone servers
- Custom frameworks

## Advanced Configuration

### Customize Protected Events:
Edit `server/backdoor_detection.lua`:
```lua
local protectedServerEvents = {
    -- Add your server-specific protected events
}
```

### Customize Cipher Detection Patterns:
Edit `server/cipher_panel_detection.lua`:
```lua
local cipherEventPatterns = {
    -- Add custom patterns
}
```

## Troubleshooting

### False Positives:
If legitimate resources are being blocked:
1. Check resource names don't match patterns
2. Whitelist in config if needed
3. Review patterns in detection files

### Performance Issues:
If experiencing lag:
1. Increase check intervals in client file
2. Reduce pattern matching complexity
3. Disable specific detection methods

## Maintenance

Regularly update:
- Cipher Panel signatures (new versions)
- Protected event list (framework updates)
- Backdoor patterns (new exploit methods)

## Support

For issues or questions:
1. Check server console for detailed logs
2. Review Discord webhook alerts
3. Enable `Config.Debug = true` for verbose logging

## Credits

Developed for enhanced FiveM server security.
Anti-Backdoor & Anti-Cipher Panel systems integrated into SLES Anti-Cheat.
