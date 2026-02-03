-- Player Statistics and Reputation System
-- Tracks player behavior and builds reputation scores

local PlayerStats = {}
local PlayerReputation = {}
local StatsFile = "player_stats.json"

-- Load player stats
function LoadPlayerStats()
    local file = LoadResourceFile(GetCurrentResourceName(), StatsFile)
    if file then
        local data = json.decode(file)
        PlayerStats = data.stats or {}
        PlayerReputation = data.reputation or {}
        print(string.format("^2[ANTI-CHEAT]^7 Loaded stats for %d players", GetTableLength(PlayerStats)))
    end
end

-- Save player stats
function SavePlayerStats()
    local data = {
        stats = PlayerStats,
        reputation = PlayerReputation
    }
    SaveResourceFile(GetCurrentResourceName(), StatsFile, json.encode(data, {indent = true}), -1)
end

function GetTableLength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Initialize player stats
function InitPlayerStats(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    
    if not PlayerStats[identifier] then
        PlayerStats[identifier] = {
            name = GetPlayerName(source),
            joinCount = 0,
            totalPlaytime = 0,
            lastSeen = os.time(),
            violations = {},
            warnings = 0,
            kicks = 0,
            bans = 0,
            reputationScore = 100,
            trustLevel = "New",
            detections = {},
            cleanTime = 0,
            adminNotes = {}
        }
    end
    
    PlayerStats[identifier].joinCount = PlayerStats[identifier].joinCount + 1
    PlayerStats[identifier].lastSeen = os.time()
    PlayerStats[identifier].name = GetPlayerName(source)
    
    -- Calculate trust level
    UpdatePlayerTrustLevel(identifier)
    
    SavePlayerStats()
end

-- Update reputation score
function UpdateReputation(source, change, reason)
    local identifier = GetPlayerIdentifiers(source)[1]
    
    if not PlayerStats[identifier] then
        InitPlayerStats(source)
    end
    
    local oldScore = PlayerStats[identifier].reputationScore
    PlayerStats[identifier].reputationScore = math.max(0, math.min(100, oldScore + change))
    
    table.insert(PlayerStats[identifier].violations, {
        reason = reason,
        change = change,
        timestamp = os.time(),
        newScore = PlayerStats[identifier].reputationScore
    })
    
    -- Update trust level based on new score
    UpdatePlayerTrustLevel(identifier)
    
    SavePlayerStats()
    
    print(string.format("^3[REPUTATION]^7 %s: %d -> %d (%s)", 
        GetPlayerName(source), oldScore, PlayerStats[identifier].reputationScore, reason))
end

-- Calculate trust level
function UpdatePlayerTrustLevel(identifier)
    local stats = PlayerStats[identifier]
    if not stats then return end
    
    local score = stats.reputationScore
    local playtime = stats.totalPlaytime or 0
    local joinCount = stats.joinCount or 0
    
    if score >= 90 and playtime > 3600 then
        stats.trustLevel = "Trusted"
    elseif score >= 75 and joinCount > 10 then
        stats.trustLevel = "Regular"
    elseif score >= 50 then
        stats.trustLevel = "Normal"
    elseif score >= 25 then
        stats.trustLevel = "Suspicious"
    else
        stats.trustLevel = "High Risk"
    end
end

-- Get player stats
function GetPlayerStats(identifier)
    return PlayerStats[identifier]
end

-- Record violation
function RecordViolation(source, violationType, details)
    local identifier = GetPlayerIdentifiers(source)[1]
    
    if not PlayerStats[identifier] then
        InitPlayerStats(source)
    end
    
    table.insert(PlayerStats[identifier].detections, {
        type = violationType,
        details = details,
        timestamp = os.time()
    })
    
    -- Decrease reputation based on violation severity
    local reputationLoss = {
        SpeedHack = -15,
        Teleport = -20,
        Godmode = -25,
        Aimbot = -30,
        CheatEngine = -50,
        RapidFire = -20,
        NoClip = -25,
        WeaponSpawn = -15,
        VehicleSpawn = -10,
        Exploit = -20
    }
    
    local loss = reputationLoss[violationType] or -10
    UpdateReputation(source, loss, violationType .. ": " .. details)
    
    SavePlayerStats()
end

-- Track playtime
CreateThread(function()
    while true do
        Wait(60000) -- Every minute
        
        for _, playerId in ipairs(GetPlayers()) do
            local source = tonumber(playerId)
            local identifier = GetPlayerIdentifiers(source)[1]
            
            if identifier and PlayerStats[identifier] then
                PlayerStats[identifier].totalPlaytime = (PlayerStats[identifier].totalPlaytime or 0) + 60
                
                -- Slowly restore reputation for clean play
                if PlayerStats[identifier].reputationScore < 100 then
                    local cleanMinutes = (PlayerStats[identifier].cleanTime or 0) + 1
                    PlayerStats[identifier].cleanTime = cleanMinutes
                    
                    -- +1 reputation every hour of clean play
                    if cleanMinutes >= 60 then
                        UpdateReputation(source, 1, "Clean playtime")
                        PlayerStats[identifier].cleanTime = 0
                    end
                end
            end
        end
        
        SavePlayerStats()
    end
end)

-- Admin command to view player stats
RegisterCommand('acinfo', function(source, args)
    if not IsPlayerAceAllowed(source, Config.AdminAce) then return end
    
    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Usage: /acinfo <player_id>"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    if not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Player not found"}
        })
        return
    end
    
    local identifier = GetPlayerIdentifiers(targetId)[1]
    local stats = PlayerStats[identifier]
    
    if stats then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^2[PLAYER INFO]", string.format("%s", stats.name)}
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3Reputation:", string.format("%d/100 - %s", stats.reputationScore, stats.trustLevel)}
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3Playtime:", string.format("%d hours", math.floor(stats.totalPlaytime / 3600))}
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3Detections:", string.format("%d violations", #stats.detections)}
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3Warnings/Kicks:", string.format("%d warnings, %d kicks", stats.warnings, stats.kicks)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "No stats available for this player"}
        })
    end
end, false)

-- Initialize
CreateThread(function()
    LoadPlayerStats()
end)

-- Player joined
AddEventHandler('playerJoining', function()
    local source = source
    InitPlayerStats(source)
end)

-- Player dropped
AddEventHandler('playerDropped', function()
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    
    if PlayerStats[identifier] then
        PlayerStats[identifier].lastSeen = os.time()
        SavePlayerStats()
    end
end)

-- Export functions
exports('GetPlayerStats', GetPlayerStats)
exports('RecordViolation', RecordViolation)
exports('UpdateReputation', UpdateReputation)
