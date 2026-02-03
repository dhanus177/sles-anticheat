Config = {}

-- General Settings
Config.ResourceName = "SLES-anticheat"
Config.Debug = false

-- Detection Settings
Config.EnableSpeedCheck = true
Config.EnableTeleportCheck = true
Config.EnableGodmodeCheck = true
Config.EnableWeaponCheck = true
Config.EnableVehicleSpawnCheck = true
Config.EnableResourceCheck = true
Config.EnableExplosionCheck = true
Config.EnableScreenCheck = true
Config.EnableCipherPanelDetection = true
Config.EnableBackdoorCheck = true

-- Godmode false-positive prevention
Config.GodmodeGracePeriod = 30 -- Seconds after spawn/join to ignore godmode checks

-- Thresholds
Config.MaxSpeed = 700.0 -- Maximum speed in units/s
Config.MaxTeleportDistance = 100.0 -- Maximum instant movement in meters
Config.CheckInterval = 5000 -- Check every 5 seconds
Config.ClientCheckInterval = 10000 -- Client checks every 10 seconds

-- Ban Settings
Config.AutoBan = true
Config.PermanentBan = true
Config.BanDuration = 168 -- Hours (7 days)
Config.BanMessage = "🛡️ Anti-Cheat: You have been banned for using unauthorized modifications"

-- Webhook Settings
Config.EnableWebhook = true
Config.WebhookURL = "https://discord.com/api/webhooks/1462346422396522517/Pz83PPj03tOLyfOrR8MsgVGNIy2A1fnAmQxGGUsVz-JZM5n2syGzzlLGupoywDuge_DM" -- Your Discord webhook URL
Config.WebhookColor = 15158332 -- Red color
Config.ScreenshotOnDetection = true -- Take screenshot on detection 
config.screenshotswebhookurl = "https://discord.com/api/webhooks/1462346422396522517/Pz83PPj03tOLyfOrR8MsgVGNIy2A1fnAmQxGGUsVz-JZM5n2syGzzlLGupoywDuge_DM" -- Your Discord webhook URL for screenshots
-- Reason Messages
-- Whitelist
Config.AdminAce = "SLES-anticheat.admin" -- ACE permission name checked by the script
Config.AdminBypassAce = "SLES-anticheat.bypass" -- ACE permission to bypass detections
-- Specific players that should fully bypass anti-cheat (use identifiers like license:, steam:, fivem:)
Config.BypassIdentifiers = {
     "license:426991012d60c4cf37432377a6cf5f652df1c0ec",  --suriya krishna
     "license:695c861522d767c2b3779c9d2679a5f27b977b6b",  --rish addam
     "license:6a83e715bc67f879d959fb0231c93274450ab844",
     "license:a72b0605ffea9f0d92467c825ad581584b5ad67c",
     "license:ee1552c4e0ae2f2ee1ace6e6f577a4a152048f77",
     "license:b649904f16757fd901a98967a439e6d2fa6463d6",
     "license:d96f85f24325a4c568189f886a1db727c698fa56",
}
Config.WhitelistedWeapons = {
    -- Add allowed weapons here
    "WEAPON_PISTOL",
    "WEAPON_NIGHTSTICK",
    "weapon_bat",
    "weapon_knife",
    "weapon_knuckle",
    "weapon_dagger",
    "weapon_wrench",
    "weapon_machete",
    "weapon_switchblade",
    "weapon_battleaxe",
    "weapon_pumpshotgun",
    "weapon_specialcarbine",
    "weapon_smg",
    "weapon_microsmg",
    "weapon_appistol",
    "weapon_heavypistol",
    "weapon_stungun",
    "weapon_carbinerifle",
    "weapon_flashlight",
    "weapon_bullpuprifle",

}

-- Protected Events (block these from being triggered by clients)
Config.ProtectedEvents = {
    "esx:giveInventoryItem",
    "esx:giveMoney",
    "esx_dmvschool:pay",
    "bank:transfer",
    "esx_billing:sendBill",
}

-- Known Cheat Resources (auto-detect and block)
Config.BlacklistedResources = {
    "eulen",
    "lynx",
    "redengine",
    "modestmenu",
    "cheat",
    "hack",
    "mod_menu",
    "Eulen Cheats",
    "Skript.gg",
    "Desudo",
    "Nexus Panel",
    "redENGINE",
    "Midnight",
    "Tiago Executor",
    "1337 Service",
    "Reborn Menu",
    "Spectra",
    "Absolute Executor",
    "X-Menu",
    "D-Panel",
    "Frosted Menu",
    "Impulse Menu",
    "Weazel News Cheat",
    "Project Homecoming",
    "AC-Menu",
    "MenuExec",
    "Firestorm Menu",
    "OneSync Infinity",
    "Brutan Premium",
    "Brutan Menu",
    "Blum Panel"
}

-- Blacklisted Vehicles (ban on spawn)
Config.BlacklistedVehicles = {
    "Chernobog",   -- Example: Uncomment to blacklist
    "Pfister Comet Safari",
    "Ocelot Stromberg"
}

-- Blacklisted Weapons (ban on spawn)
Config.BlacklistedWeapons = {
    -- "WEAPON_MINIGUN",  -- Example: Uncomment to blacklist
    -- "WEAPON_RPG",
}

-- Screenshot Check
Config.EnableScreenshotCheck = true
Config.ScreenshotInterval = 60000 -- Screenshot every 60 seconds
Config.ScreenshotQuality = 0.5
Config.ScreenshotOnDetection = true -- Auto-screenshot when cheat detected
Config.RandomScreenshots = true -- Random player screenshots
Config.RandomScreenshotInterval = 300000 -- 5 minutes

-- Client Scanner Settings
Config.RequireClientScanner = false -- Set to true to FORCE players to run scanner (kicks if not running)
Config.RecommendClientScanner = false -- Set to true to WARN players (doesn't kick, just reminds)
Config.ClientScannerUrl = "https://github.com/yourusername/clientscanner/releases/download/v1.0/ClientScanner.exe" -- Download link for players
Config.ScannerHeartbeatTimeout = 120 -- Seconds before considering scanner offline
Config.ShowDownloadPrompt = false -- Show download prompt when player joins
Config.DownloadPromptInterval = 300 -- Show prompt every 5 minutes if not running scanner
Config.KickOnScannerClose = false -- Kick players who close scanner after joining (recommended)

-- HWID Ban Settings
Config.EnableHWIDBans = true

-- Player Reputation System
Config.EnableReputation = true
Config.AutoKickLowReputation = false -- Kick players below certain score
Config.MinimumReputation = 20 -- Minimum score before auto-kick

-- Admin Commands
Config.AdminAce = "SLES-anticheat.admin" -- ACE permission name checked by the script

-- Admin Panel
Config.EnableAdminPanel = true -- In-game GUI (F10)
Config.AdminPanelKey = "F10" -- Keybind to open panel
Config.AdminAce = "SLES-anticheat.admin" -- Change this to match your server.cfg ACE name

-- txAdmin Integration
Config.TxAdminIntegration = true -- Sync bans with txAdmin

-- Framework Protection
Config.ProtectFrameworkEvents = true -- Block ESX/QBCore exploits
-- Safe Zone Settings with pNotify
Config.pNotify = true
Config.pNotifyEnterMessage = "You entered SLES Safe Zone. Please Remove your Helmet and Mask"
Config.pNotifyEnterType = "error"
Config.pNotifyExitMessage = "You left SLES Safe Zone"
Config.pNotifyExitType = "warning"

-- Safe Zones - Players entering while invincible will be automatically banned
Config.Zones = {
    {
        {320.73, -327.47, 49.3}, -- motel park
        {310.29, -358.19, 45.06},
        {301.56, -359.51, 45.19},
        {292.74, -365.4, 45.05},
        {247.71, -349.22, 44.32},
        {259.57, -305.21, 49.65},
    },
    {
        {265.12, -612.52, 42.39}, -- hospital
        {289.74, -552.6, 43.15},
        {401.2, -560.96, 44.67},
        {349.67, -642.27, 36.72},
    },
    {
        {-885.21, -1208.22, 4.95}, -- viceroy
        {-808.11, -1161.69, 8.35},
        {-726.58, -1227.95, 10.62},
        {-768.13, -1279.27, 5.15},
        {-835.12, -1268.13, 5.0},
    },
    {
        {458.86, -1026.98, 28.43}, -- police
        {405.26, -1032.77, 29.33},
        {411.21, -961.8, 29.47},
        {461.36, -961.13, 28.22},
    },
    {
        {156.5, -3005.72, 7.03}, -- garage
        {117.78, -3006.57, 6.02},
        {118.65, -3072.26, 6.02},
        {155.81, -3072.07, 7.03},
    },
    {
        {-183.98, -1296.74, 31.3}, -- benis
        {-185.65, -1346.1, 31.11},
        {-251.8, -1345.95, 31.31},
        {-253.15, -1298.94, 31.29},
    },
    {
        {-15.05, -1121.57, 27.24}, -- pdm
        {-78.52, -1122.36, 25.74},
        {-58.33, -1064.39, 27.55},
        {-1.7, -1081.68, 26.67},
    },
    {
        {-1276.5, -356.04, 36.64}, -- luxury
        {-1268.37, -377.35, 36.54},
        {-1226.25, -352.37, 37.33},
        {-1235.69, -335.97, 37.3},
    }
}

Config.SafeZoneRadius = 100.0 -- Detection radius for safe zones
Config.SafeZoneCheckInterval = 1000 -- Check every 1 second if player is in safe zone