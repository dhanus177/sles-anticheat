-- Server-side admin panel handlers

-- Helper: unified admin permission check (ACE or txAdmin)
local function HasAdminPermission(src)
    -- Primary: ACE permission defined in Config.AdminAce (e.g., 'anticheat.admin')
    if IsPlayerAceAllowed(src, Config.AdminAce) then return true end

    -- Fallback: txAdmin admin status if monitor resource is running
    if GetResourceState('monitor') == 'started' and exports['monitor'] then
        local isAdminFunc = exports['monitor'].isPlayerAdmin
        if type(isAdminFunc) == 'function' then
            if exports['monitor']:isPlayerAdmin(src) then
                return true
            end
        end
    end

    return false
end

local function GetConfigSnapshot()
    return {
        EnableSpeedCheck = Config.EnableSpeedCheck,
        EnableTeleportCheck = Config.EnableTeleportCheck,
        EnableGodmodeCheck = Config.EnableGodmodeCheck,
        EnableWeaponCheck = Config.EnableWeaponCheck,
        EnableVehicleSpawnCheck = Config.EnableVehicleSpawnCheck,
        EnableResourceCheck = Config.EnableResourceCheck,
        EnableExplosionCheck = Config.EnableExplosionCheck,
        EnableScreenCheck = Config.EnableScreenCheck,
        EnableBackdoorCheck = Config.EnableBackdoorCheck,
        EnableCipherPanelDetection = Config.EnableCipherPanelDetection,
        EnableBehavioralDetection = Config.EnableBehavioralDetection,
        EnableScreenshotCheck = Config.EnableScreenshotCheck,
        ScreenshotOnDetection = Config.ScreenshotOnDetection,
        RandomScreenshots = Config.RandomScreenshots,
        EnableHWIDBans = Config.EnableHWIDBans,
        AutoBan = Config.AutoBan,
        MaxSpeed = Config.MaxSpeed,
        MaxTeleportDistance = Config.MaxTeleportDistance,
        CheckInterval = Config.CheckInterval,
        ClientCheckInterval = Config.ClientCheckInterval,
        GodmodeGracePeriod = Config.GodmodeGracePeriod,
        AimbotMinShots = Config.AimbotMinShots,
        AimbotHeadshotRatioThreshold = Config.AimbotHeadshotRatioThreshold,
        AimSnapDeltaThreshold = Config.AimSnapDeltaThreshold,
        AimSnapShotWindowMs = Config.AimSnapShotWindowMs,
        AimAccelThresholdDegPerSec2 = Config.AimAccelThresholdDegPerSec2,
        AverageTTKMs = Config.AverageTTKMs,
        RequireClientScanner = Config.RequireClientScanner,
        RecommendClientScanner = Config.RecommendClientScanner,
        ScannerHeartbeatTimeout = Config.ScannerHeartbeatTimeout,
        KickOnScannerClose = Config.KickOnScannerClose
    }
end

-- Check if player is admin
RegisterServerEvent('anticheat:checkAdmin')
AddEventHandler('anticheat:checkAdmin', function()
    local source = source
    
    if source == 0 then return end
    
    local playerName = GetPlayerName(source)
    local hasPermission = HasAdminPermission(source)
    
    print(string.format("^3[ADMIN-PANEL]^7 Access request from %s - Permission: %s - ACE: %s", 
        playerName, tostring(hasPermission), Config.AdminAce))
    
    if hasPermission then
        TriggerClientEvent('anticheat:openPanel', source)
        print(string.format("^2[ADMIN-PANEL]^7 Panel opened for %s", playerName))
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to access the admin panel. Contact server admin."}
        })
        print(string.format("^1[ADMIN-PANEL]^7 Denied panel access for %s - Missing ACE: %s", playerName, Config.AdminAce))
    end
end)

-- Send player list
RegisterServerEvent('anticheat:requestPlayerList')
AddEventHandler('anticheat:requestPlayerList', function()
    local source = source
    
    if source == 0 or not HasAdminPermission(source) then return end
    
    local players = {}
    
    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        local identifier = GetPlayerIdentifiers(pid)[1]
        local stats = PlayerStats and PlayerStats[identifier]
        
        table.insert(players, {
            id = pid,
            name = GetPlayerName(pid),
            reputation = stats and stats.reputationScore or 100,
            trustLevel = stats and stats.trustLevel or "New",
            violations = stats and #stats.detections or 0
        })
    end
    
    TriggerClientEvent('anticheat:receivePlayerList', source, players)
end)

-- Send player info
RegisterServerEvent('anticheat:requestPlayerInfo')
AddEventHandler('anticheat:requestPlayerInfo', function(playerId)
    local source = source
    
    if source == 0 or not HasAdminPermission(source) then return end
    
    if not GetPlayerName(playerId) then return end
    
    local identifier = GetPlayerIdentifiers(playerId)[1]
    local stats = PlayerStats and PlayerStats[identifier]
    
    local info = {
        id = playerId,
        name = GetPlayerName(playerId),
        reputation = stats and stats.reputationScore or 100,
        trustLevel = stats and stats.trustLevel or "New",
        playtime = stats and math.floor(stats.totalPlaytime / 3600) or 0,
        violations = stats and #stats.detections or 0,
        warnings = stats and stats.warnings or 0,
        kicks = stats and stats.kicks or 0
    }
    
    TriggerClientEvent('anticheat:receivePlayerInfo', source, info)
end)

-- Send ban list
RegisterServerEvent('anticheat:requestBanList')
AddEventHandler('anticheat:requestBanList', function()
    local source = source
    
    if source == 0 or not HasAdminPermission(source) then return end
    
    TriggerClientEvent('anticheat:receiveBanList', source, Bans or {})
end)

-- Send recent detections
RegisterServerEvent('anticheat:requestRecentDetections')
AddEventHandler('anticheat:requestRecentDetections', function()
    local source = source

    if source == 0 or not HasAdminPermission(source) then return end

    local detections = GetRecentDetections and GetRecentDetections() or {}
    TriggerClientEvent('anticheat:receiveDetections', source, detections)
end)

-- Send config snapshot
RegisterServerEvent('anticheat:requestConfig')
AddEventHandler('anticheat:requestConfig', function()
    local source = source

    if source == 0 or not HasAdminPermission(source) then return end

    TriggerClientEvent('anticheat:receiveConfig', source, GetConfigSnapshot())
end)

-- Update config value
RegisterServerEvent('anticheat:updateConfigValue')
AddEventHandler('anticheat:updateConfigValue', function(key, value)
    local source = source
    
    if source == 0 or not HasAdminPermission(source) then return end
    
    if Config[key] ~= nil then
        Config[key] = value
        
        -- Send updated config to all admins
        TriggerClientEvent('anticheat:receiveConfig', source, GetConfigSnapshot())
        TriggerClientEvent('anticheat:notify', source, string.format('Config updated: %s = %s', key, tostring(value)), 'success')
        
        local adminName = GetPlayerName(source)
        print(string.format('^3[ADMIN-PANEL]^7 %s updated config: %s = %s', adminName, key, tostring(value)))
        
        if Config.EnableWebhook and SendWebhook then
            SendWebhook('⚙️ Config Update', string.format(
                '**Admin:** %s\n**Setting:** %s\n**Value:** %s',
                adminName, key, tostring(value)
            ))
        end
    else
        TriggerClientEvent('anticheat:notify', source, 'Invalid config key', 'error')
    end
end)

-- Send stats
RegisterServerEvent('anticheat:requestStats')
AddEventHandler('anticheat:requestStats', function()
    local source = source
    
    if source == 0 or not HasAdminPermission(source) then return end
    
    local stats = {
        onlinePlayers = #GetPlayers(),
        totalBans = Bans and #Bans or 0,
        recentDetections = (GetRecentDetections and #GetRecentDetections()) or 0,
        hwidBans = HWIDBans and #HWIDBans or 0
    }
    
    TriggerClientEvent('anticheat:receiveStats', source, stats)
end)

-- Handle admin actions
RegisterServerEvent('anticheat:adminAction')
AddEventHandler('anticheat:adminAction', function(action, targetId, data)
    local source = source
    
    if source == 0 or not IsPlayerAceAllowed(source, Config.AdminAce) then return end
    
    local adminName = GetPlayerName(source)
    
    if action == 'ban' then
        if not GetPlayerName(targetId) then return end
        
        local identifier = GetPlayerIdentifiers(targetId)[1]
        local playerName = GetPlayerName(targetId)
        
        AddBan(identifier, playerName, data, "Admin Ban")
        
        if Config.EnableHWIDBans then
            exports['anticheat']:AddHWIDBan(targetId, data)
        end
        
        if PlayerStats and PlayerStats[identifier] then
            PlayerStats[identifier].bans = (PlayerStats[identifier].bans or 0) + 1
            SavePlayerStats()
        end
        
        DropPlayer(targetId, "Banned by admin: " .. data)
        
        TriggerClientEvent('anticheat:notify', source, "Player banned successfully", "success")
        
        if Config.EnableWebhook then
            SendWebhook("🔨 Admin Ban", string.format(
                "**Admin:** %s\n**Player:** %s\n**Reason:** %s",
                adminName, playerName, data
            ))
        end
        
    elseif action == 'kick' then
        if not GetPlayerName(targetId) then return end
        
        local identifier = GetPlayerIdentifiers(targetId)[1]
        if PlayerStats and PlayerStats[identifier] then
            PlayerStats[identifier].kicks = (PlayerStats[identifier].kicks or 0) + 1
            SavePlayerStats()
        end
        
        DropPlayer(targetId, "Kicked by admin: " .. data)
        
        TriggerClientEvent('anticheat:notify', source, "Player kicked successfully", "success")
        
    elseif action == 'warn' then
        if not GetPlayerName(targetId) then return end
        
        local identifier = GetPlayerIdentifiers(targetId)[1]
        if PlayerStats and PlayerStats[identifier] then
            PlayerStats[identifier].warnings = (PlayerStats[identifier].warnings or 0) + 1
            SavePlayerStats()
        end
        
        TriggerClientEvent('chat:addMessage', targetId, {
            args = {"^3[WARNING]", data}
        })
        
        TriggerClientEvent('anticheat:notify', source, "Player warned successfully", "success")
        
    elseif action == 'freeze' then
        TriggerClientEvent('anticheat:freeze', targetId, true)
        TriggerClientEvent('anticheat:notify', source, "Player frozen", "success")
        
    elseif action == 'unfreeze' then
        TriggerClientEvent('anticheat:freeze', targetId, false)
        TriggerClientEvent('anticheat:notify', source, "Player unfrozen", "success")
        
    elseif action == 'screenshot' then
        if exports['anticheat'] and exports['anticheat'].RequestPlayerScreenshot then
            exports['anticheat']:RequestPlayerScreenshot(targetId, "Admin Request")
            TriggerClientEvent('anticheat:notify', source, "Screenshot requested", "success")
        end
        
    elseif action == 'goto' then
        if not GetPlayerName(targetId) then return end
        
        local targetPed = GetPlayerPed(targetId)
        local targetCoords = GetEntityCoords(targetPed)
        
        SetEntityCoords(GetPlayerPed(source), targetCoords.x, targetCoords.y, targetCoords.z)
        TriggerClientEvent('anticheat:notify', source, "Teleported to player", "success")
        
    elseif action == 'bring' then
        if not GetPlayerName(targetId) then return end
        
        local adminPed = GetPlayerPed(source)
        local adminCoords = GetEntityCoords(adminPed)
        
        SetEntityCoords(GetPlayerPed(targetId), adminCoords.x, adminCoords.y, adminCoords.z)
        TriggerClientEvent('anticheat:notify', source, "Player brought to you", "success")
        
    elseif action == 'unban' then
        -- data contains identifier
        RemoveBan(data)
        TriggerClientEvent('anticheat:notify', source, "Player unbanned successfully", "success")
        
        -- Refresh ban list
        TriggerClientEvent('anticheat:receiveBanList', source, Bans or {})
        
    elseif action == 'banhwid' then
        if not GetPlayerName(targetId) then return end
        
        local playerName = GetPlayerName(targetId)
        
        if Config.EnableHWIDBans then
            if AddHWIDBan then
                AddHWIDBan(targetId, data)
                TriggerClientEvent('anticheat:notify', source, "Player HWID banned successfully", "success")
                
                if Config.EnableWebhook then
                    SendWebhook("⛔ HWID Ban", string.format(
                        "**Admin:** %s\n**Player:** %s\n**Reason:** %s",
                        adminName, playerName, data
                    ))
                end
            else
                TriggerClientEvent('anticheat:notify', source, "HWID ban system not available", "error")
            end
        else
            TriggerClientEvent('anticheat:notify', source, "HWID bans are disabled", "error")
        end
    end
end)
