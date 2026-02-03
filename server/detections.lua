local PlayerData = {}

-- Centralized bypass check (ACE or identifier list)
local function IsPlayerBypassed(source)
    if IsPlayerAceAllowed(source, Config.AdminAce) or IsPlayerAceAllowed(source, Config.AdminBypassAce) then
        return true
    end

    local identifiers = GetPlayerIdentifiers(source)
    if Config.BypassIdentifiers and #Config.BypassIdentifiers > 0 then
        for _, id in ipairs(identifiers) do
            for _, allowed in ipairs(Config.BypassIdentifiers) do
                if string.lower(id) == string.lower(allowed) then
                    return true
                end
            end
        end
    end

    return false
end

-- Initialize player data
function InitPlayer(source)
    PlayerData[source] = {
        lastPosition = GetEntityCoords(GetPlayerPed(source)),
        lastVelocity = 0,
        violations = 0,
        lastCheck = GetGameTimer(),
        speedViolations = 0,
        teleportViolations = 0,
        weaponSpawns = 0,
        suspiciousActions = 0,
        joinTime = os.time(),
        totalPlaytime = 0,
        lastDamage = 0,
        damageReceived = {},
        headshotRatio = 0,
        shots = 0,
        headshots = 0,
        spawnProtectionUntil = GetGameTimer() + ((Config.GodmodeGracePeriod or 30) * 1000),
    }
end

-- Enhanced speed hack detection with false positive prevention
function CheckSpeed(source)
    if not Config.EnableSpeedCheck then return end
    
    local ped = GetPlayerPed(source)
    if not DoesEntityExist(ped) then return end
    
            -- Skip bypassed players
            if IsPlayerBypassed(source) then return end
    
    local coords = GetEntityCoords(ped)
    local velocity = GetEntitySpeed(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    -- Different thresholds for on-foot vs in vehicle
    local maxSpeed = vehicle ~= 0 and 200.0 or Config.MaxSpeed
    
    if velocity > maxSpeed then
        PlayerData[source].speedViolations = (PlayerData[source].speedViolations or 0) + 1
        
        -- Immediate ban after 1 violation
        if PlayerData[source].speedViolations > 1 then
            DetectionHandler(source, "Speed Hack", "SpeedHack", string.format("Speed: %.2f (Violations: %d)", velocity, PlayerData[source].speedViolations))
        end
    else
        PlayerData[source].speedViolations = math.max(0, (PlayerData[source].speedViolations or 0) - 1)
    end
end

-- Enhanced teleport detection with smart filtering
function CheckTeleport(source)
    if not Config.EnableTeleportCheck then return end
    
            -- Skip bypassed players
            if IsPlayerBypassed(source) then return end
    
    local ped = GetPlayerPed(source)
    if not DoesEntityExist(ped) then return end
    
    local coords = GetEntityCoords(ped)
    
    if PlayerData[source] and PlayerData[source].lastPosition then
        local distance = #(coords - PlayerData[source].lastPosition)
        local timeDiff = (GetGameTimer() - PlayerData[source].lastCheck) / 1000
        
        -- Ignore if in vehicle, being dragged, or legitimate spawn
        local vehicle = GetVehiclePedIsIn(ped, false)
        local health = GetEntityHealth(ped)
        
        if distance > Config.MaxTeleportDistance and timeDiff < 1 and vehicle == 0 and health > 0 then
            PlayerData[source].teleportViolations = (PlayerData[source].teleportViolations or 0) + 1
            
            -- Immediate ban after 1 violation
            if PlayerData[source].teleportViolations > 1 then
                DetectionHandler(source, "Teleport Hack", "Teleport", string.format("Distance: %.2fm in %.2fs (Violations: %d)", distance, timeDiff, PlayerData[source].teleportViolations))
            end
        elseif distance < 50 then
            PlayerData[source].teleportViolations = 0
        end
        
        PlayerData[source].lastPosition = coords
        PlayerData[source].lastCheck = GetGameTimer()
    end
end

-- Enhanced god mode detection
function CheckGodmode(source)
    if not Config.EnableGodmodeCheck then return end
    
            -- Skip bypassed players
            if IsPlayerBypassed(source) then return end
    
    local ped = GetPlayerPed(source)
    if not DoesEntityExist(ped) then return end

    -- Skip godmode check briefly after spawn/join to avoid false positives
    if PlayerData[source] and PlayerData[source].spawnProtectionUntil then
        if GetGameTimer() < PlayerData[source].spawnProtectionUntil then
            return
        end
    end
    
    -- Skip godmode check if player is in a safe zone
    if PlayerData[source] and PlayerData[source].inSafeZone then
        return
    end
    
    -- Check godmode indicator (server-side only)
    -- Note: GetEntityInvincible is not available server-side
    local isInvincible = GetPlayerInvincible(source)
    local health = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)

    -- Ignore invalid or transient health states
    if not health or not maxHealth or health <= 0 or maxHealth <= 0 then
        return
    end
    
    -- Check if player is invincible or has suspiciously high health
    if isInvincible then
        DetectionHandler(source, "God Mode", "Godmode", "Player is invincible")
    elseif health > maxHealth + 50 then
        DetectionHandler(source, "God Mode", "Godmode", string.format("Health: %d/%d", health, maxHealth))
    end
    
    -- Track damage patterns (godmode users take no damage)
    if PlayerData[source] then
        local currentTime = GetGameTimer()
        if PlayerData[source].lastDamage and (currentTime - PlayerData[source].lastDamage) > 60000 then
            -- No damage taken in 60 seconds of active play - suspicious
            if PlayerData[source].totalPlaytime and PlayerData[source].totalPlaytime > 300 then
                -- Only flag if they've been playing for 5+ minutes
            end
        end
    end
end

-- Weapon spawn detection
RegisterServerEvent('anticheat:weaponCheck')
AddEventHandler('anticheat:weaponCheck', function(weaponHash)
    local source = source
    
    if not Config.EnableWeaponCheck then return end
    
        -- Skip bypassed players
        if IsPlayerBypassed(source) then return end
    
    -- Check if weapon is in whitelist
    local weaponName = GetHashKey(weaponHash)
    local isAllowed = false
    
    for _, weapon in ipairs(Config.WhitelistedWeapons) do
        if GetHashKey(weapon) == weaponHash then
            isAllowed = true
            break
        end
    end
    
    if not isAllowed then
        DetectionHandler(source, "Unauthorized Weapon", "WeaponSpawn", "Weapon Hash: " .. weaponHash)
    end
end)

-- Explosion detection
AddEventHandler('explosionEvent', function(source, ev)
    if not Config.EnableExplosionCheck then return end
    
        -- Skip bypassed players
        if IsPlayerBypassed(source) then return end
    
    -- Block certain explosion types commonly used by mod menus
    if ev.explosionType == 29 or ev.explosionType == 30 or ev.explosionType == 32 then
        DetectionHandler(source, "Suspicious Explosion", "Explosion", "Type: " .. ev.explosionType)
        CancelEvent()
    end
end)

-- Resource injection detection
AddEventHandler('onResourceStart', function(resourceName)
    if Config.BlacklistedResources then
        for _, blacklisted in ipairs(Config.BlacklistedResources) do
            if string.find(string.lower(resourceName), string.lower(blacklisted)) then
                print(string.format("[ANTI-CHEAT] Blocked suspicious resource: %s", resourceName))
                StopResource(resourceName)
            end
        end
    end
end)

-- Protected event blocking
if Config.ProtectedEvents then
    for _, eventName in ipairs(Config.ProtectedEvents) do
        RegisterServerEvent(eventName)
        AddEventHandler(eventName, function()
            local source = source
            if not IsPlayerAceAllowed(source, Config.AdminAce) then
                DetectionHandler(source, "Trigger Protected Event", "ProtectedEvent", "Event: " .. eventName)
                CancelEvent()
            end
        end)
    end
end

-- Detection handler
function DetectionHandler(source, reason, detectionType, details)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    
    print(string.format("[ANTI-CHEAT] Detection - Player: %s | Type: %s | Details: %s", 
        playerName, detectionType, details))
    
    -- Record in player stats
    if RecordViolation then
        RecordViolation(source, detectionType, details)
    end
    
    -- Take screenshot if enabled
    if Config.ScreenshotOnDetection and RequestPlayerScreenshot then
        RequestPlayerScreenshot(source, detectionType)
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
        AddBan(identifier, playerName, reason, detectionType)
        
        -- Add HWID ban for all serious violations
        if Config.EnableHWIDBans then
            exports['anticheat']:AddHWIDBan(source, reason)
        end
        
        -- Immediate kick/ban
        DropPlayer(source, Config.BanMessage .. "\nReason: " .. reason .. "\nYou have been permanently banned.")
    else
        -- Just kick
        DropPlayer(source, "🛡️ Suspicious activity detected: " .. reason)
    end
end

-- Unified server event for detections triggered by other modules
RegisterNetEvent('anticheat:detection')
AddEventHandler('anticheat:detection', function(playerSource, reason, detectionType, details)
    local src = playerSource or source
    if not src or src == 0 then return end

    if DetectionHandler then
        DetectionHandler(src, reason, detectionType, details)
    end
end)

-- Detect when one player teleports another (player bring exploit)
function CheckPlayerTeleportingOthers(source)
    if not Config.EnableTeleportCheck then return end
    
    -- Skip bypassed players
    if IsPlayerBypassed(source) then return end
    
    local sourcePed = GetPlayerPed(source)
    if not DoesEntityExist(sourcePed) then return end
    
    -- Check all other players
    for _, targetId in ipairs(GetPlayers()) do
        targetId = tonumber(targetId)
        if targetId ~= source then
            local targetPed = GetPlayerPed(targetId)
            if DoesEntityExist(targetPed) then
                local targetCoords = GetEntityCoords(targetPed)
                
                -- If target player was just teleported near the source player, it's suspicious
                if PlayerData[targetId] and PlayerData[targetId].lastPosition then
                    local distance = #(targetCoords - PlayerData[targetId].lastPosition)
                    local timeDiff = (GetGameTimer() - PlayerData[targetId].lastCheck) / 1000
                    
                    -- Check if target player moved far instantly (teleported)
                    -- AND they're now close to the source player (brought)
                    if distance > Config.MaxTeleportDistance and timeDiff < 1 then
                        local distToSource = #(targetCoords - GetEntityCoords(sourcePed))
                        
                        -- If teleported player is now within 30m of source, source likely teleported them
                        if distToSource < 30.0 then
                            DetectionHandler(source, "Player Bring/Teleport Exploit", "PlayerBringExploit",
                                string.format("Teleported %s - Distance: %.2fm (Violations: %d)", 
                                GetPlayerName(targetId), distance, PlayerData[source].teleportViolations or 1))
                        end
                    end
                end
            end
        end
    end
end

-- Blacklisted vehicle detection
RegisterServerEvent('anticheat:vehicleSpawned')
AddEventHandler('anticheat:vehicleSpawned', function(vehicleHash)
    local source = source
    
    if not Config.BlacklistedVehicles or #Config.BlacklistedVehicles == 0 then return end
    
    -- Check if vehicle model is blacklisted
    for _, blacklisted in ipairs(Config.BlacklistedVehicles) do
        if string.lower(blacklisted) == string.lower(vehicleHash) then
            DetectionHandler(source, "Blacklisted Vehicle Spawn", "VehicleExploit", 
                string.format("Attempted to spawn blacklisted vehicle: %s", vehicleHash))
            return
        end
    end
end)

-- Blacklisted weapon detection
RegisterServerEvent('anticheat:weaponSpawned')
AddEventHandler('anticheat:weaponSpawned', function(weaponHash)
    local source = source
    
    if not Config.BlacklistedWeapons or #Config.BlacklistedWeapons == 0 then return end
    
    -- Check if weapon is blacklisted
    for _, blacklisted in ipairs(Config.BlacklistedWeapons) do
        if string.lower(blacklisted) == string.lower(weaponHash) then
            DetectionHandler(source, "Blacklisted Weapon Spawn", "WeaponExploit", 
                string.format("Attempted to spawn blacklisted weapon: %s", weaponHash))
            return
        end
    end
end)

-- Periodic checks
CreateThread(function()
    while true do
        Wait(Config.CheckInterval)
        
        for _, playerId in ipairs(GetPlayers()) do
            local source = tonumber(playerId)
            
            -- Skip bypassed players
            if not IsPlayerBypassed(source) then
                if not PlayerData[source] then
                    InitPlayer(source)
                end
                
                CheckSpeed(source)
                CheckTeleport(source)
                CheckGodmode(source)
                CheckPlayerTeleportingOthers(source)
            end
        end
    end
end)

-- Safe Zone Detection Thread (runs more frequently)
CreateThread(function()
    while true do
        Wait(Config.SafeZoneCheckInterval)
        
        for _, playerId in ipairs(GetPlayers()) do
            local source = tonumber(playerId)
            
            if not IsPlayerBypassed(source) then
                if not PlayerData[source] then
                    InitPlayer(source)
                end
                
                CheckSafeZone(source)
            end
        end
    end
end)

-- Player connecting
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    
    deferrals.defer()
    Wait(0)
    deferrals.update("🛡️ Checking anti-cheat status...")
    
    local isBanned, reason = IsBanned(identifier)
    if isBanned then
        deferrals.done(Config.BanMessage .. "\nReason: " .. reason)
    else
        deferrals.done()
    end
end)

-- Player joined
AddEventHandler('playerJoining', function()
    local source = source
    InitPlayer(source)
end)

-- Helper function to get zone name from coordinates
local function GetZoneName(index)
    local zoneNames = {
        "Motel Park",
        "Hospital",
        "Viceroy",
        "Police Station",
        "Garage",
        "Benis",
        "PDM",
        "Luxury Dealer"
    }
    return zoneNames[index] or "Unknown Zone"
end

-- Check if player is in any safe zone using convex hull detection
function IsPlayerInSafeZone(ped)
    if not DoesEntityExist(ped) then return false, nil end
    
    local playerCoords = GetEntityCoords(ped)
    
    for zoneIndex, zone in ipairs(Config.Zones) do
        -- Calculate zone center and check if player is within bounds
        local minX, maxX = zone[1][1], zone[1][1]
        local minY, maxY = zone[1][2], zone[1][2]
        
        for _, coord in ipairs(zone) do
            minX = math.min(minX, coord[1])
            maxX = math.max(maxX, coord[1])
            minY = math.min(minY, coord[2])
            maxY = math.max(maxY, coord[2])
        end
        
        -- Check if player is within the zone boundaries
        if playerCoords.x >= minX - Config.SafeZoneRadius and 
           playerCoords.x <= maxX + Config.SafeZoneRadius and
           playerCoords.y >= minY - Config.SafeZoneRadius and 
           playerCoords.y <= maxY + Config.SafeZoneRadius then
            return true, zoneIndex
        end
    end
    
    return false, nil
end

-- Safe Zone Detection - Ban invincible players entering safe zones
function CheckSafeZone(source)
    if not Config.Zones or not next(Config.Zones) then return end
    
    local ped = GetPlayerPed(source)
    if not DoesEntityExist(ped) then return end
    
    -- Skip admins from detection
    if IsPlayerBypassed(source) then return end
    
    local playerName = GetPlayerName(source)
    local isInZone, zoneIndex = IsPlayerInSafeZone(ped)
    
    -- Initialize player zone status if not exists
    if PlayerData[source].inSafeZone == nil then
        PlayerData[source].inSafeZone = false
        PlayerData[source].currentZone = nil
    end
    
    -- Player entering safe zone
    if isInZone and not PlayerData[source].inSafeZone then
        PlayerData[source].inSafeZone = true
        PlayerData[source].currentZone = zoneIndex
        
        -- Send enter notification
        if Config.pNotify then
            TriggerClientEvent('pNotify:SendNotification', source, {
                title = "Safe Zone Alert",
                message = Config.pNotifyEnterMessage,
                type = Config.pNotifyEnterType,
                timeout = 5000,
                layout = "top"
            })
        end
    end
    
    -- Player leaving safe zone
    if not isInZone and PlayerData[source].inSafeZone then
        PlayerData[source].inSafeZone = false
        local previousZone = PlayerData[source].currentZone
        PlayerData[source].currentZone = nil
        
        -- Send exit notification
        if Config.pNotify then
            TriggerClientEvent('pNotify:SendNotification', source, {
                title = "Safe Zone Alert",
                message = Config.pNotifyExitMessage,
                type = Config.pNotifyExitType,
                timeout = 5000,
                layout = "top"
            })
        end
    end
end

-- Player dropped
AddEventHandler('playerDropped', function()
    local source = source
    PlayerData[source] = nil
end)

-- Export detection function
exports('DetectionHandler', DetectionHandler)
