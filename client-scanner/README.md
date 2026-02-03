# Client Scanner - Anti-Cheat Process Monitor

## What It Does
Runs in the background (system tray) and scans for blacklisted cheat processes every 5 seconds:
- Cheat Engine (CE)
- Eulen, Lynx, RedEngine
- Blum Panel, X-Menu, D-Panel
- Mod menus, executors, injectors

When detected:
- Reports to FiveM server via HTTP POST
- Shows warning balloon notification
- Server auto-kicks/bans the player

## How to Build
```bash
cd client-scanner
dotnet publish -c Release -r win-x64 --self-contained
```

Output: `bin/Release/net8.0-windows/win-x64/publish/ClientScanner.exe`

## Configuration
Create or edit `ClientScanner.config.json` next to the EXE:
```json
{
    "serverUrl": "http://YOUR_SERVER_IP:30120/anticheat-client",
    "scanIntervalMs": 5000,
    "heartbeatIntervalMs": 30000,
    "maxMissedHeartbeats": 3
}
```
**Tip:** Run as Administrator for best detection coverage.

## Watchdog (Anti‑Tamper)
The scanner includes a watchdog that exits if the scan loop stalls. This helps detect tampering.

## GitHub Builds & Releases
This repo includes GitHub Actions workflows:
- **CI build** uploads `ClientScanner.exe` as an artifact on every push/PR
- **Release build** runs on tags like `v1.0.0` and publishes assets

Release asset URL format:
```
https://github.com/<your-user>/<your-repo>/releases/download/v1.0.0/ClientScanner.exe
```

## How to Use
1. **Distribute to players**: Host the .exe on your website or Discord
2. **Require before joining**: Add server rule that players must run it
3. **Auto-start**: Players add to Windows startup (optional)
4. **Server endpoint**: Update `serverUrl` in `Program.cs` to your FiveM IP

## Server Integration
Already added in `server/main.lua`:
```lua
SetHttpHandler(function(req, res)
    if req.path == '/anticheat-client' and req.method == 'POST' then
        -- Auto-kick player when cheat detected
    end
end)
```

## Requirements
- Windows 10/11
- .NET 8 Runtime (or use --self-contained build)
- Admin privileges (to scan all processes)

## Detection List
Currently scans for 20+ known cheat tools. Edit `BlacklistedProcesses` array to add more.
