-- Advanced behavioral analysis and pattern detection
-- Detects aimbot, triggerbot, and other suspicious behavior

local PlayerStats = {}

local function EnsurePlayerStats(source)
    PlayerStats[source] = PlayerStats[source] or {}
    PlayerStats[source].shots = PlayerStats[source].shots or 0
    PlayerStats[source].hits = PlayerStats[source].hits or 0
    PlayerStats[source].headshots = PlayerStats[source].headshots or 0
    PlayerStats[source].headshotRatio = PlayerStats[source].headshotRatio or 0
    PlayerStats[source].recentShots = PlayerStats[source].recentShots or {}
    PlayerStats[source].suspiciousAim = PlayerStats[source].suspiciousAim or 0
    PlayerStats[source].consecutiveHeadshots = PlayerStats[source].consecutiveHeadshots or 0
    PlayerStats[source].lastHeadshotTime = PlayerStats[source].lastHeadshotTime or 0
    PlayerStats[source].longDistanceHeadshots = PlayerStats[source].longDistanceHeadshots or 0
    PlayerStats[source].rapidFireViolations = PlayerStats[source].rapidFireViolations or 0
    return PlayerStats[source]
end

local function CanTriggerBehavioralDetection(source, key)
    local now = GetGameTimer()
    PlayerStats[source] = PlayerStats[source] or {}
    PlayerStats[source].cooldowns = PlayerStats[source].cooldowns or {}

    local last = PlayerStats[source].cooldowns[key] or 0
    local baseCooldown = Config.BehavioralDetectionCooldownMs or 15000
    local ttk = Config.AverageTTKMs or 0
    local ttkMult = Config.BehavioralCooldownTTKMultiplier or 2
    local ttkCooldown = ttk > 0 and (ttk * ttkMult) or 0
    local cooldown = math.max(baseCooldown, ttkCooldown)
    if now - last < cooldown then
        return false
    end

    PlayerStats[source].cooldowns[key] = now
    return true
end

-- Aimbot detection via headshot ratio analysis
RegisterServerEvent('anticheat:shotFired')
AddEventHandler('anticheat:shotFired', function(isHeadshot, targetServerId, distance, isTargetPlayer)
    local source = source

    if not Config.EnableBehavioralDetection then return end
    
    -- Skip admins from detection
    if IsPlayerAceAllowed(source, "SLES-anticheat.bypass") then return end

    local stats = EnsurePlayerStats(source)

    stats.shots = stats.shots + 1
    
    if isHeadshot then
        stats.headshots = stats.headshots + 1
        stats.hits = stats.hits + 1

        local now = GetGameTimer()
        if now - (stats.lastHeadshotTime or 0) <= (Config.AimbotConsecutiveWindowMs or 2000) then
            stats.consecutiveHeadshots = (stats.consecutiveHeadshots or 0) + 1
        else
            stats.consecutiveHeadshots = 1
        end
        stats.lastHeadshotTime = now

        if distance and distance > 0 and distance >= (Config.ESPLongDistanceThreshold or 120.0) then
            stats.longDistanceHeadshots = (stats.longDistanceHeadshots or 0) + 1
        end
    else
        stats.consecutiveHeadshots = 0
    end
    
    -- Calculate headshot ratio
    if stats.shots > (Config.AimbotMinShots or 50) then
        local headshotRatio = (stats.headshots / stats.shots) * 100
        
        -- Suspicious if headshot ratio is extremely high
        if headshotRatio > (Config.AimbotHeadshotRatioThreshold or 70) then
            stats.suspiciousAim = (stats.suspiciousAim or 0) + 1
            
            if stats.suspiciousAim >= (Config.AimbotSuspicionCount or 5) and
               CanTriggerBehavioralDetection(source, "aimbot_ratio") then
                DetectionHandler(source, "Aimbot Suspected", "Aimbot", 
                    string.format("Headshot ratio: %.1f%% (%d/%d shots)", 
                        headshotRatio, stats.headshots, stats.shots))
            end
        end
    end

    -- Consecutive headshot streaks (highly suspicious)
    if stats.consecutiveHeadshots and
       stats.consecutiveHeadshots >= (Config.AimbotConsecutiveHeadshots or 8) and
       CanTriggerBehavioralDetection(source, "aimbot_streak") then
        DetectionHandler(source, "Aimbot Suspected", "Aimbot", 
            string.format("Consecutive headshots: %d", stats.consecutiveHeadshots))
        stats.consecutiveHeadshots = 0
    end

    -- Long-distance headshot clusters (possible ESP/aim assistance)
    if stats.longDistanceHeadshots and
       stats.longDistanceHeadshots >= (Config.ESPLongDistanceHeadshots or 6) and
       CanTriggerBehavioralDetection(source, "esp_longrange") then
        DetectionHandler(source, "ESP/Aimbot Suspected", "ESP", 
            string.format("Long-distance headshots: %d (>= %.1fm)",
                stats.longDistanceHeadshots, (Config.ESPLongDistanceThreshold or 120.0)))
        stats.longDistanceHeadshots = 0
    end
end)

RegisterServerEvent('anticheat:aimSnap')
AddEventHandler('anticheat:aimSnap', function(delta, dt, shotDelta)
    local source = source

    if not Config.EnableBehavioralDetection then return end
    if IsPlayerAceAllowed(source, Config.AdminBypassAce) then return end

    if shotDelta and Config.AimSnapShotWindowMs and shotDelta > Config.AimSnapShotWindowMs then
        return
    end

    local stats = EnsurePlayerStats(source)
    stats.aimSnap = stats.aimSnap or { count = 0, windowStart = GetGameTimer() }

    local now = GetGameTimer()
    local window = Config.AimSnapWindowMs or 4000

    if now - stats.aimSnap.windowStart > window then
        stats.aimSnap.count = 0
        stats.aimSnap.windowStart = now
    end

    stats.aimSnap.count = stats.aimSnap.count + 1

    if stats.aimSnap.count >= (Config.AimSnapViolations or 3) and
       CanTriggerBehavioralDetection(source, "aimsnap") then
        DetectionHandler(source, "Aim Snap Suspected", "AimSnap",
            string.format("Delta: %.1f deg, Interval: %dms", delta or -1, dt or -1))
        stats.aimSnap.count = 0
    end
end)

RegisterServerEvent('anticheat:aimAccel')
AddEventHandler('anticheat:aimAccel', function(accel, delta, dt)
    local source = source

    if not Config.EnableBehavioralDetection then return end
    if IsPlayerAceAllowed(source, Config.AdminBypassAce) then return end

    local stats = EnsurePlayerStats(source)
    stats.aimAccel = stats.aimAccel or { count = 0, windowStart = GetGameTimer() }

    local now = GetGameTimer()
    local window = Config.AimAccelWindowMs or 4000

    if now - stats.aimAccel.windowStart > window then
        stats.aimAccel.count = 0
        stats.aimAccel.windowStart = now
    end

    stats.aimAccel.count = stats.aimAccel.count + 1

    if stats.aimAccel.count >= (Config.AimAccelViolations or 3) and
       CanTriggerBehavioralDetection(source, "aimaccel") then
        DetectionHandler(source, "Aim Acceleration Suspected", "AimAccel",
            string.format("Accel: %.1f deg/s^2, Delta: %.1f deg, Interval: %dms", accel or -1, delta or -1, dt or -1))
        stats.aimAccel.count = 0
    end
end)

-- Rapid fire detection
local LastShotTime = {}

RegisterServerEvent('anticheat:weaponFired')
AddEventHandler('anticheat:weaponFired', function()
        local source = source

    if not Config.EnableBehavioralDetection then return end
    
        -- Skip admins from detection
    if IsPlayerAceAllowed(source, Config.AdminBypassAce) then return end

    local source = source
    local currentTime = GetGameTimer()
    
    if LastShotTime[source] then
        local timeDiff = currentTime - LastShotTime[source]
        
        -- If shooting faster than threshold (inhuman for semi-auto)
        if timeDiff < (Config.RapidFireMinIntervalMs or 60) then
            local stats = EnsurePlayerStats(source)
            
            local violations = (stats.rapidFireViolations or 0) + 1
            stats.rapidFireViolations = violations
            
            if violations > (Config.RapidFireViolations or 25) and
               CanTriggerBehavioralDetection(source, "rapidfire") then
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

-- TTK Tracker (average time-to-kill)
local TTKTracker = {}
local TTKStats = {
    totalMs = 0,
    count = 0,
    lastAvgMs = 0
}

local function ReportTTKIfReady()
    local sample = Config.TTKSampleSize or 100
    if TTKStats.count > 0 then
        TTKStats.lastAvgMs = math.floor(TTKStats.totalMs / TTKStats.count)
    end

    if TTKStats.count >= sample then
        local avgSec = TTKStats.lastAvgMs / 1000.0
        print(string.format("^3[ANTI-CHEAT]^7 Average TTK: %.2fs (samples: %d)", avgSec, TTKStats.count))
        -- Keep rolling average (don't reset) so it stays stable
    end
end

AddEventHandler('gameEventTriggered', function(name, args)
    if not Config.EnableTTKTracker then return end
    if name ~= 'CEventNetworkEntityDamage' then return end

    local victim = args[1]
    local attacker = args[2]
    local isFatal = args[6]

    if not victim or not DoesEntityExist(victim) then return end
    if not IsEntityAPed(victim) or not IsPedAPlayer(victim) then return end

    local victimPlayer = NetworkGetPlayerIndexFromPed(victim)
    if victimPlayer == -1 then return end

    local victimServerId = GetPlayerServerId(victimPlayer)
    if not victimServerId then return end

    local now = GetGameTimer()
    TTKTracker[victimServerId] = TTKTracker[victimServerId] or { firstDamageAt = 0 }

    if TTKTracker[victimServerId].firstDamageAt == 0 then
        TTKTracker[victimServerId].firstDamageAt = now
    end

    local fatal = (isFatal == 1 or isFatal == true)
    if not fatal and DoesEntityExist(victim) then
        local health = GetEntityHealth(victim)
        if health and health <= 0 then
            fatal = true
        end
    end

    if fatal then
        local start = TTKTracker[victimServerId].firstDamageAt
        if start and start > 0 then
            local ttkMs = now - start
            if ttkMs > 0 and ttkMs < 60000 then
                TTKStats.totalMs = TTKStats.totalMs + ttkMs
                TTKStats.count = TTKStats.count + 1
                ReportTTKIfReady()
            end
        end
        TTKTracker[victimServerId].firstDamageAt = 0
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    if TTKTracker[source] then
        TTKTracker[source] = nil
    end
end)
