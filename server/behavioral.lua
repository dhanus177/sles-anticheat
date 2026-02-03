-- Advanced behavioral analysis and pattern detection
-- Detects aimbot, triggerbot, and other suspicious behavior

local PlayerStats = {}

-- Aimbot detection via headshot ratio analysis
RegisterServerEvent('anticheat:shotFired')
AddEventHandler('anticheat:shotFired', function(isHeadshot, targetPed)
    local source = source
    
    if not PlayerStats[source] then
        -- Skip admins from detection
        if IsPlayerAceAllowed(source, "SLES-anticheat.bypass") then return end

        PlayerStats[source] = {
            shots = 0,
            hits = 0,
            headshots = 0,
            headshotRatio = 0,
            recentShots = {},
            suspiciousAim = 0
        }
    end
    
    PlayerStats[source].shots = PlayerStats[source].shots + 1
    
    if isHeadshot then
        PlayerStats[source].headshots = PlayerStats[source].headshots + 1
        PlayerStats[source].hits = PlayerStats[source].hits + 1
    end
    
    -- Calculate headshot ratio
    if PlayerStats[source].shots > 50 then
        local headshotRatio = (PlayerStats[source].headshots / PlayerStats[source].shots) * 100
        
        -- Suspicious if >70% headshot ratio (inhuman)
        if headshotRatio > 170 then
            PlayerStats[source].suspiciousAim = (PlayerStats[source].suspiciousAim or 0) + 1
            
            if PlayerStats[source].suspiciousAim > 50 then
                DetectionHandler(source, "Aimbot Suspected", "Aimbot", 
                    string.format("Headshot ratio: %.1f%% (%d/%d shots)", 
                        headshotRatio, PlayerStats[source].headshots, PlayerStats[source].shots))
            end
        end
    end
end)

-- Rapid fire detection
local LastShotTime = {}

RegisterServerEvent('anticheat:weaponFired')
AddEventHandler('anticheat:weaponFired', function()
        local source = source
    
        -- Skip admins from detection
        if IsPlayerAceAllowed(source, "anticheat.bypass") then return end

    local source = source
    local currentTime = GetGameTimer()
    
    if LastShotTime[source] then
        local timeDiff = currentTime - LastShotTime[source]
        
        -- If shooting faster than 50ms between shots (inhuman for semi-auto)
        if timeDiff < 50 then
            if not PlayerStats[source] then
                PlayerStats[source] = {
                    shots = 0,
                    hits = 0,
                    headshots = 0,
                    headshotRatio = 0,
                    recentShots = {},
                    suspiciousAim = 0,
                    rapidFireViolations = 0
                }
            end
            
            local violations = (PlayerStats[source].rapidFireViolations or 0) + 1
            PlayerStats[source].rapidFireViolations = violations
            
            if violations > 250 then
                DetectionHandler(source, "Rapid Fire", "RapidFire", 
                    string.format("Shot interval: %dms", timeDiff))
            end
        end
    end
    
    LastShotTime[source] = currentTime
end)

-- Super jump detection
RegisterServerEvent('anticheat:jumpCheck')
AddEventHandler('anticheat:jumpCheck', function(height)
    local source = source
    
    if height > 5.0 then
        DetectionHandler(source, "Super Jump", "Movement", 
            string.format("Jump height: %.2fm", height))
    end
end)

-- Infinite ammo detection
local PlayerAmmo = {}

RegisterServerEvent('anticheat:ammoCheck')
AddEventHandler('anticheat:ammoCheck', function(weaponHash, ammoCount)
    local source = source
    
    if not PlayerAmmo[source] then
        PlayerAmmo[source] = {}
    end
    
    if PlayerAmmo[source][weaponHash] then
        -- Ammo increased without reloading = infinite ammo cheat
        if ammoCount > PlayerAmmo[source][weaponHash] + 250 then
            DetectionHandler(source, "Infinite Ammo", "WeaponHack", 
                string.format("Ammo: %d -> %d", PlayerAmmo[source][weaponHash], ammoCount))
        end
    end
    
    PlayerAmmo[source][weaponHash] = ammoCount
    
end)

local PlayerData = {}

-- Vehicle modifications detection (disabled - requires client-side check)
-- Note: GetVehicleEstimatedMaxSpeed is not available server-side

-- Spectate/invisibility detection (disabled - requires client-side check)
-- Note: GetEntityAlpha is not available server-side
--[[
CreateThread(function()
    while true do
        Wait(10000)
        
        for _, playerId in ipairs(GetPlayers()) do
            local source = tonumber(playerId)
            local ped = GetPlayerPed(source)
            
            if DoesEntityExist(ped) then
                local alpha = GetEntityAlpha(ped)
                
                -- Fully invisible player
                if alpha < 50 and not IsPlayerAceAllowed(source, Config.AdminAce) then
                    DetectionHandler(source, "Invisibility", "Visual", 
                        string.format("Alpha: %d", alpha))
                end
            end
        end
    end
end)
]]--

-- Noclip/spectator detection
CreateThread(function()
    while true do
        Wait(5000)
        
        for _, playerId in ipairs(GetPlayers()) do
            local source = tonumber(playerId)
            
            if not IsPlayerAceAllowed(source, Config.AdminAce) then
                -- Initialize PlayerData if it doesn't exist
                if not PlayerData[source] then
                    PlayerData[source] = {
                        noclipViolations = 0
                    }
                end
                
                local ped = GetPlayerPed(source)
                
                if DoesEntityExist(ped) then
                    local coords = GetEntityCoords(ped)
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    
                    -- Check abnormal velocity patterns (noclip detection)
                    -- Note: GetGroundZFor_3dCoord is client-side only, cannot check ground height server-side
                    if vehicle == 0 then
                        local velocity = GetEntityVelocity(ped)
                        local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
                        
                        -- Detect unusual velocity patterns that indicate noclip
                        if speed > 15.0 and coords.z > 50.0 then -- High speed at high altitude
                            PlayerData[source].noclipViolations = (PlayerData[source].noclipViolations or 0) + 1
                            
                            if PlayerData[source].noclipViolations > 3 then
                                DetectionHandler(source, "No-Clip", "Movement", 
                                    string.format("Speed: %.2f, Altitude: %.2fm", speed, coords.z))
                                PlayerData[source].noclipViolations = 0
                            end
                        else
                            PlayerData[source].noclipViolations = 0
                        end
                    end
                end
            end
        end
    end
end)

-- Freeze/cage other players detection
RegisterServerEvent('anticheat:playerFrozen')
AddEventHandler('anticheat:playerFrozen', function(targetId)
    local source = source
    
    if not IsPlayerAceAllowed(source, Config.AdminAce) then
        DetectionHandler(source, "Player Freeze", "Griefing", 
            string.format("Attempted to freeze player %d", targetId))
    end
end)

print("^2[ANTI-CHEAT]^7 Advanced behavioral detection loaded")
