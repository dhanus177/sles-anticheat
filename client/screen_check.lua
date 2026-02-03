if Config.EnableScreenshotCheck then
    local function sendScreenshot()
        local webhook = Config.WebhookURL
        if not webhook or webhook == "" then return end

        local playerId = GetPlayerServerId(PlayerId())
        local playerName = GetPlayerName(PlayerId()) or "Unknown"

        -- Use screenshot-basic upload directly to Discord webhook with metadata
        if exports and exports["screenshot-basic"] and exports["screenshot-basic"].requestClientScreenshotUpload then
            exports['screenshot-basic']:requestClientScreenshotUpload(webhook, {
                encoding = 'jpg',
                quality = Config.ScreenshotQuality or 0.5,
                headers = {
                    ['Content-Type'] = 'multipart/form-data'
                },
                fields = {
                    ['content'] = string.format("Screenshot from %s (ID: %s) @ %s", playerName, tostring(playerId), os.date("%Y-%m-%d %H:%M:%S"))
                }
            }, function(err, data)
                -- Optional: log locally if needed
                if err and Config.Debug then
                    print("[ANTI-CHEAT] Screenshot upload failed: " .. tostring(err))
                end
            end)
        elseif Config.Debug then
            print("[ANTI-CHEAT] screenshot-basic not found; cannot capture overlay screenshots")
        end
    end

    CreateThread(function()
        while true do
            Wait(Config.ScreenshotInterval)
            sendScreenshot()
        end
    end)
end

-- Detect overlay indicators
CreateThread(function()
    while true do
        Wait(10000)
        
        -- Check for common overlay patterns
        -- This is limited but can detect some basic overlays
        
        local screenWidth, screenHeight = GetActiveScreenResolution()
        
        -- Most mod menus draw UI elements
        -- We can't directly detect them but can look for suspicious behavior
    end
end)
