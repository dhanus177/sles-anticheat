-- Hardware ID (HWID) Ban System
-- Prevents banned players from rejoining with new accounts

local HWIDBans = {}
local HWIDBanFile = "hwid_bans.json"

-- Load HWID bans
function LoadHWIDBans()
    local file = LoadResourceFile(GetCurrentResourceName(), HWIDBanFile)
    if file then
        HWIDBans = json.decode(file) or {}
        print(string.format("^2[ANTI-CHEAT]^7 Loaded %d HWID bans", #HWIDBans))
    else
        HWIDBans = {}
    end
end

-- Save HWID bans
function SaveHWIDBans()
    SaveResourceFile(GetCurrentResourceName(), HWIDBanFile, json.encode(HWIDBans, {indent = true}), -1)
end

-- Get player's hardware identifiers
function GetPlayerHWID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local hwid = nil
    
    for _, id in ipairs(identifiers) do
        if string.match(id, "discord:") or string.match(id, "license:") then
            -- Use multiple identifiers for better tracking
            hwid = id
            break
        end
    end
    
    return hwid or "unknown"
end

-- Add HWID ban
function AddHWIDBan(source, reason)
    local hwid = GetPlayerHWID(source)
    local playerName = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    local ban = {
        hwid = hwid,
        identifiers = identifiers,
        playerName = playerName,
        reason = reason,
        timestamp = os.time(),
        banCount = 1
    }
    
    -- Check if already banned
    for i, existingBan in ipairs(HWIDBans) do
        if existingBan.hwid == hwid then
            HWIDBans[i].banCount = existingBan.banCount + 1
            HWIDBans[i].reason = reason
            HWIDBans[i].timestamp = os.time()
            SaveHWIDBans()
            return
        end
    end
    
    table.insert(HWIDBans, ban)
    SaveHWIDBans()
    
    print(string.format("^1[HWID-BAN]^7 %s banned (HWID: %s)", playerName, hwid))
    
    if Config.EnableWebhook then
        SendWebhook("🔨 HWID Ban", string.format(
            "**Player:** %s\n**HWID:** %s\n**Reason:** %s\n**Ban Count:** %d",
            playerName, hwid, reason, ban.banCount
        ))
    end
end

-- Check if player is HWID banned
function IsHWIDBanned(source)
    local hwid = GetPlayerHWID(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    for _, ban in ipairs(HWIDBans) do
        if ban.hwid == hwid then
            return true, ban.reason, ban.banCount
        end
        
        -- Check all identifiers
        for _, bannedId in ipairs(ban.identifiers) do
            for _, playerId in ipairs(identifiers) do
                if bannedId == playerId then
                    return true, ban.reason, ban.banCount
                end
            end
        end
    end
    
    return false, nil, 0
end

-- Remove HWID ban
function RemoveHWIDBan(hwid)
    for i, ban in ipairs(HWIDBans) do
        if ban.hwid == hwid then
            table.remove(HWIDBans, i)
            SaveHWIDBans()
            return true
        end
    end
    return false
end

-- Check on player connecting
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    
    deferrals.defer()
    Wait(0)
    
    local isBanned, reason, banCount = IsHWIDBanned(source)
    
    if isBanned then
        deferrals.done(string.format(
            "🔨 HARDWARE BAN\n\nYou are permanently banned from this server.\nReason: %s\n\nAttempts to evade: %d\n\nThis ban cannot be appealed.",
            reason, banCount
        ))
        
        print(string.format("^1[HWID-BAN]^7 Blocked connection attempt from HWID banned player: %s (Attempt #%d)", name, banCount))
        
        if Config.EnableWebhook then
            SendWebhook("🚫 HWID Ban Evasion Attempt", string.format(
                "**Player:** %s\n**Reason:** %s\n**Attempt:** #%d",
                name, reason, banCount
            ))
        end
    end
end)

-- Initialize
CreateThread(function()
    LoadHWIDBans()
end)

-- Export functions
exports('AddHWIDBan', AddHWIDBan)
exports('IsHWIDBanned', IsHWIDBanned)
exports('RemoveHWIDBan', RemoveHWIDBan)
