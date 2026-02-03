local BannedPlayers = {}
local BanFilePath = "bans.json"

-- Load bans from file
function LoadBans()
    local file = LoadResourceFile(GetCurrentResourceName(), BanFilePath)
    if file then
        BannedPlayers = json.decode(file) or {}
        print("[ANTI-CHEAT] Loaded " .. #BannedPlayers .. " bans")
    else
        BannedPlayers = {}
        print("[ANTI-CHEAT] No existing ban file found")
    end
end

-- Save bans to file
function SaveBans()
    SaveResourceFile(GetCurrentResourceName(), BanFilePath, json.encode(BannedPlayers, {indent = true}), -1)
end

-- Add ban
function AddBan(identifier, playerName, reason, detectionType)
    local ban = {
        identifier = identifier,
        playerName = playerName,
        reason = reason,
        detectionType = detectionType,
        timestamp = os.time(),
        permanent = Config.PermanentBan,
        expiryTime = Config.PermanentBan and 0 or (os.time() + (Config.BanDuration * 3600))
    }
    
    table.insert(BannedPlayers, ban)
    SaveBans()
    
    print(string.format("[ANTI-CHEAT] Banned %s (%s) - %s", playerName, identifier, reason))
    
    -- Send webhook notification
    if Config.EnableWebhook and Config.WebhookURL ~= "" then
        SendWebhook("Player Banned", string.format("**Player:** %s\n**Identifier:** %s\n**Reason:** %s\n**Type:** %s", 
            playerName, identifier, reason, detectionType))
    end
end

-- Check if player is banned
function IsBanned(identifier)
    for _, ban in ipairs(BannedPlayers) do
        if ban.identifier == identifier then
            if ban.permanent then
                return true, ban.reason
            elseif os.time() < ban.expiryTime then
                return true, ban.reason
            end
        end
    end
    return false, nil
end

-- Remove ban
function RemoveBan(identifier)
    for i, ban in ipairs(BannedPlayers) do
        if ban.identifier == identifier then
            table.remove(BannedPlayers, i)
            SaveBans()
            return true
        end
    end
    return false
end

-- Send Discord webhook
function SendWebhook(title, description)
    if not Config.EnableWebhook or Config.WebhookURL == "" then return end
    
    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
    end, 'POST', json.encode({
        embeds = {{
            title = title,
            description = description,
            color = Config.WebhookColor,
            footer = {
                text = "Anti-Cheat System"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }), {['Content-Type'] = 'application/json'})
end

-- Initialize
CreateThread(function()
    LoadBans()
end)

-- Export functions
exports('AddBan', AddBan)
exports('IsBanned', IsBanned)
exports('RemoveBan', RemoveBan)
