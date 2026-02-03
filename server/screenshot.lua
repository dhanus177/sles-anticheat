-- Screenshot System for detecting overlays and mod menus
-- Requires screenshot-basic resource

local ScreenshotQueue = {}
local LastScreenshot = {}

-- Request screenshot from player
function RequestPlayerScreenshot(source, reason)
    if not Config.EnableScreenshotCheck then return end
    
    -- Rate limit screenshots
    if LastScreenshot[source] and (os.time() - LastScreenshot[source]) < 30 then
        return
    end
    
    LastScreenshot[source] = os.time()
    
    -- Check if screenshot-basic is available
    if GetResourceState('screenshot-basic') ~= 'started' then
        print("^3[ANTI-CHEAT]^7 screenshot-basic resource not found")
        return
    end
    
    local playerName = GetPlayerName(source)
    
    exports['screenshot-basic']:requestClientScreenshot(source, {
        encoding = 'jpg',
        quality = 0.8
    }, function(err, data)
        if err then
            print(string.format("^1[SCREENSHOT]^7 Error capturing from %s: %s", playerName, err))
            return
        end
        
        -- Save screenshot
        local filename = string.format("screenshots/%s_%s_%d.jpg", 
            playerName:gsub("[^%w]", "_"), 
            reason:gsub("[^%w]", "_"),
            os.time())
        
        SaveResourceFile(GetCurrentResourceName(), filename, data, -1)
        
        print(string.format("^2[SCREENSHOT]^7 Captured from %s - Reason: %s", playerName, reason))
        
        -- Send to webhook
        if Config.EnableWebhook and (Config.ScreenshotsWebhookURL or Config.WebhookURL) ~= "" then
            SendWebhookWithImage("📸 Screenshot Captured", string.format(
                "**Player:** %s\n**Reason:** %s\n**Time:** %s",
                playerName, reason, os.date("%Y-%m-%d %H:%M:%S")
            ), data)
        end
    end)
end

-- Auto-screenshot on detection
function AutoScreenshot(source, detectionType)
    if Config.ScreenshotOnDetection then
        RequestPlayerScreenshot(source, "Detection: " .. detectionType)
    end
end

-- Periodic random screenshots
if Config.RandomScreenshots then
    CreateThread(function()
        while true do
            Wait(Config.RandomScreenshotInterval or 300000) -- Default 5 minutes
            
            local players = GetPlayers()
            if #players > 0 then
                local randomPlayer = tonumber(players[math.random(#players)])
                RequestPlayerScreenshot(randomPlayer, "Random Check")
            end
        end
    end)
end

-- Admin command to request screenshot
RegisterCommand('acscreenshot', function(source, args)
    if not IsPlayerAceAllowed(source, Config.AdminAce) then return end
    
    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Usage: /acscreenshot <player_id>"}
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
    
    RequestPlayerScreenshot(targetId, "Admin Request")
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTI-CHEAT]", "Screenshot requested from " .. GetPlayerName(targetId)}
    })
end, false)

-- Send screenshot to Discord with image
function SendWebhookWithImage(title, description, imageData)
    if not Config.EnableWebhook then return end
    local webhookUrl = Config.ScreenshotsWebhookURL or Config.WebhookURL
    if not webhookUrl or webhookUrl == "" then return end

    local function base64decode(data)
        if not data then return "" end
        data = data:gsub("[^%w%+/%=]", "")
        return (data:gsub(".", function(x)
            if x == "=" then return "" end
            local r, f = "", ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/":find(x) - 1)
            for i = 6, 1, -1 do
                r = r .. (f % 2^i - f % 2^(i - 1) > 0 and "1" or "0")
            end
            return r
        end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
            if #x ~= 8 then return "" end
            local c = 0
            for i = 1, 8 do
                c = c + (x:sub(i, i) == "1" and 2^(8 - i) or 0)
            end
            return string.char(c)
        end))
    end

    local boundary = "----anticheat-boundary-" .. tostring(os.time())
    local payload = json.encode({
        embeds = {
            {
                title = title,
                description = description,
                color = 15158332,
                image = { url = "attachment://screenshot.jpg" },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
            }
        }
    })

    local binaryImage = base64decode(tostring(imageData))

    local body = table.concat({
        "--" .. boundary,
        "Content-Disposition: form-data; name=\"payload_json\"",
        "Content-Type: application/json",
        "",
        payload,
        "--" .. boundary,
        "Content-Disposition: form-data; name=\"files[0]\"; filename=\"screenshot.jpg\"",
        "Content-Type: image/jpeg",
        "",
        binaryImage,
        "--" .. boundary .. "--",
        ""
    }, "\r\n")

    PerformHttpRequest(webhookUrl, function(err, text, headers)
        if err ~= 200 then
            print(string.format("^1[WEBHOOK]^7 Error sending screenshot: %d", err))
        end
    end, 'POST', body, {['Content-Type'] = 'multipart/form-data; boundary=' .. boundary})
end

-- Send embed to webhook
function SendWebhookEmbed(embed)
    if not Config.EnableWebhook or Config.WebhookURL == "" then return end
    
    local payload = json.encode({
        embeds = {embed}
    })
    
    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
        if err ~= 200 then
            print(string.format("^1[WEBHOOK]^7 Error sending embed: %d", err))
        end
    end, 'POST', payload, {['Content-Type'] = 'application/json'})
end

-- Export
exports('RequestPlayerScreenshot', RequestPlayerScreenshot)
exports('AutoScreenshot', AutoScreenshot)
