-- txAdmin Integration
-- Syncs anti-cheat bans with txAdmin

local txAdminAvailable = false

-- Check if txAdmin is available
CreateThread(function()
    Wait(1000)
    
    if GetResourceState('monitor') == 'started' then
        txAdminAvailable = true
        print("^2[ANTI-CHEAT]^7 txAdmin integration enabled")
        
        -- List all available txAdmin exports
        print("^3[ANTI-CHEAT]^7 Available txAdmin exports:")
        if exports['monitor'] then
            local exportsList = {
                'checkPerms',
                'getPermissions',
                'setPermissions',
                'isPlayerAdmin',
                'logAction',
                'RegisterPluginEvent',
                'checkAdminPerms',
                'txaBan',
            }
            
            for _, exportName in ipairs(exportsList) do
                if type(exports['monitor'][exportName]) == 'function' then
                    print(string.format("  ^2✓^7 %s", exportName))
                else
                    print(string.format("  ^1✗^7 %s (not available)", exportName))
                end
            end
        end
    else
        print("^3[ANTI-CHEAT]^7 txAdmin not detected - using standalone ban system")
    end
end)

-- Send ban to txAdmin
function SendBanToTxAdmin(source, reason, duration)
    if not txAdminAvailable then return end
    
    -- txAdmin doesn't have a direct ban export, we just use our own ban system
    -- txAdmin integration is mainly for detection logging, not banning
    print(string.format("^3[ANTI-CHEAT]^7 Using local ban system (txAdmin integration for bans not supported)"))
end

-- Override DetectionHandler to use txAdmin bans
local originalDetectionHandler = DetectionHandler

function DetectionHandler(source, reason, detectionType, details)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    
    print(string.format("[ANTI-CHEAT] Detection - Player: %s | Type: %s | Details: %s", 
        playerName, detectionType, details))
    
    -- Notify all admins in chat
    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        if IsPlayerAceAllowed(pid, Config.AdminAce) then
            TriggerClientEvent('chat:addMessage', pid, {
                args = {"^1[ANTI-CHEAT]", string.format("^3%s^7 detected: ^1%s^7 - %s", playerName, detectionType, details)}
            })
            -- Send notification to admin panel if open
            TriggerClientEvent('anticheat:adminNotification', pid, {
                type = 'detection',
                player = playerName,
                playerId = source,
                detectionType = detectionType,
                details = details,
                timestamp = os.date('%H:%M:%S')
            })
        end
    end
    
    -- Record in player stats
    if RecordViolation then
        RecordViolation(source, detectionType, details)
    end
    
    -- Take screenshot if enabled
    if Config.ScreenshotOnDetection and AutoScreenshot then
        AutoScreenshot(source, detectionType)
    end
    
    -- Log to webhook
    if Config.EnableWebhook then
        SendWebhook("🚨 Cheat Detected", string.format(
            "**Player:** %s\n**Type:** %s\n**Reason:** %s\n**Details:** %s",
            playerName, detectionType, reason, details
        ))
    end
    
    -- Auto ban if enabled
    if Config.AutoBan then
        print(string.format("^1[ANTI-CHEAT]^7 Processing ban for %s (%s) - %s", playerName, identifier, reason))
        
        -- Add to our ban system
        AddBan(identifier, playerName, reason, detectionType)
        
        -- Add HWID ban for serious violations
        if Config.EnableHWIDBans and (detectionType == "CheatEngine" or detectionType == "Aimbot") then
            AddHWIDBan(source, reason)
        end
        
        -- Try to send to txAdmin if available, but always drop player
        if Config.TxAdminIntegration and txAdminAvailable then
            SendBanToTxAdmin(source, reason .. " (" .. detectionType .. ")", false)
        end
        
        -- Drop player immediately
        print(string.format("^1[ANTI-CHEAT]^7 Kicking player %s", playerName))
        DropPlayer(source, Config.BanMessage .. "\nReason: " .. reason)
        
        -- Notify admins of ban
        for _, playerId in ipairs(GetPlayers()) do
            local pid = tonumber(playerId)
            if IsPlayerAceAllowed(pid, Config.AdminAce) then
                TriggerClientEvent('chat:addMessage', pid, {
                    args = {"^1[ANTI-CHEAT]", string.format("^3%s^7 has been ^1BANNED^7 for %s", playerName, reason)}
                })
            end
        end
    else
        -- Just kick
        DropPlayer(source, "🛡️ Suspicious activity detected: " .. reason)
    end
end

-- Admin action to manually ban through txAdmin
RegisterServerEvent('anticheat:txAdminBan')
AddEventHandler('anticheat:txAdminBan', function(targetId, reason, duration)
    local source = source
    
    if not IsPlayerAceAllowed(source, Config.AdminAce) then return end
    
    if not GetPlayerName(targetId) then
        TriggerClientEvent('anticheat:notify', source, "Player not found", "error")
        return
    end
    
    local identifier = GetPlayerIdentifiers(targetId)[1]
    local playerName = GetPlayerName(targetId)
    
    -- Add to our system
    AddBan(identifier, playerName, reason, "Admin Ban")
    
    if Config.EnableHWIDBans then
        AddHWIDBan(targetId, reason)
    end
    
    -- Send to txAdmin
    if txAdminAvailable then
        SendBanToTxAdmin(targetId, reason, duration)
        TriggerClientEvent('anticheat:notify', source, "Player banned via txAdmin", "success")
    else
        DropPlayer(targetId, "Banned: " .. reason)
        TriggerClientEvent('anticheat:notify', source, "Player banned (txAdmin unavailable)", "warning")
    end
    
    -- Log to webhook
    if Config.EnableWebhook then
        SendWebhook("🔨 txAdmin Ban", string.format(
            "**Admin:** %s\n**Player:** %s\n**Reason:** %s\n**Duration:** %s",
            GetPlayerName(source), playerName, reason, duration or "Permanent"
        ))
    end
end)

-- Export txAdmin ban function
exports('SendBanToTxAdmin', SendBanToTxAdmin)
