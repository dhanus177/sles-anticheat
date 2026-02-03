-- Anti-Cipher Panel Detection System
-- Detects and prevents Cipher Panel usage

local cipherDetections = {}
local suspiciousEvents = {}

-- Known Cipher Panel event patterns
local cipherEventPatterns = {
    "cipher",
    "cipherpanel",
    "cipher_panel",
    "ciphermenu",
    "cipher:.*",
    "panel:admin",
    "panel:trigger",
    "blum",
    "blumpanel",
    "blum.*panel",
    "blum.*menu",
    "xmenu",
    "x.*menu",
    "dpanel",
    "d.*panel",
}

-- Known Cipher Panel commands
local cipherCommands = {
    "cipher",
    "cpanel",
    "ciphermenu",
    "cmenu",
    "cipheradmin",
    "blum",
    "blumpanel",
    "blummenu",
    "xmenu",
    "dpanel",
}

-- Cipher Panel typically uses these exploit methods
local cipherExploitEvents = {
    "cipher:executeCommand",
    "cipher:giveItem",
    "cipher:setJob",
    "cipher:teleport",
    "cipher:godmode",
    "cipher:noclip",
    "cipher:money",
    "cipherPanel:inject",
    "cipherMenu:trigger",
    "blum:executeCommand",
    "blum:giveItem",
    "blum:setJob",
    "blum:teleport",
    "blum:godmode",
    "blum:noclip",
    "blum:money",
    "blumPanel:inject",
    "blumMenu:trigger",
    "xmenu:trigger",
    "dpanel:trigger",
}

-- Register blocked events for Cipher Panel
for _, eventName in ipairs(cipherExploitEvents) do
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(...)
        local source = source
        local playerName = GetPlayerName(source)
        local args = {...}
        
        cipherDetections[source] = (cipherDetections[source] or 0) + 1
        
        print(string.format("^1[ANTI-CIPHER]^7 %s triggered Cipher Panel event: %s", playerName, eventName))
        
        -- Immediate ban on first detection
        TriggerEvent('anticheat:detection', source, "Cipher Panel", "CipherPanel", 
            string.format("Event: %s (Detection #%d)", eventName, cipherDetections[source]))
        
        if Config.WebhookURL then
            TriggerEvent('anticheat:sendWebhook', {
                title = "🔴 Cipher Panel Detected",
                description = string.format("Player: **%s**\nEvent: **%s**\nArguments: ```%s```\nDetections: %d", 
                    playerName, eventName, json.encode(args), cipherDetections[source]),
                color = 16711680
            })
        end
    end)
end

-- Monitor for suspicious resource injection (Cipher Panel method)
AddEventHandler('onResourceStart', function(resourceName)
    local lowerName = string.lower(resourceName)
    
    -- Check for Cipher Panel patterns
    for _, pattern in ipairs(cipherEventPatterns) do
        if string.match(lowerName, pattern) then
            print(string.format("^1[ANTI-CIPHER]^7 Cipher Panel resource detected: %s", resourceName))
            
            -- Stop the resource immediately
            StopResource(resourceName)
            
            if Config.WebhookURL then
                TriggerEvent('anticheat:sendWebhook', {
                    title = "🚨 Cipher Panel Resource Blocked",
                    description = string.format("Resource: **%s**\nAction: Stopped immediately", resourceName),
                    color = 16711680
                })
            end
            
            print(string.format("^1[ANTI-CIPHER]^7 Blocked Cipher Panel resource: %s", resourceName))
            return
        end
    end
end)

-- Detect Cipher Panel command execution
RegisterCommand('cipher', function(source, args, rawCommand)
    if source == 0 then return end -- Console is allowed
    
    local playerName = GetPlayerName(source)
    
    print(string.format("^1[ANTI-CIPHER]^7 %s attempted Cipher Panel command: %s", playerName, rawCommand))
    
    TriggerEvent('anticheat:detection', source, "Cipher Panel Command", "CipherCommand", 
        string.format("Command: %s", rawCommand))
    
    if Config.WebhookURL then
        TriggerEvent('anticheat:sendWebhook', {
            title = "⚠️ Cipher Panel Command Blocked",
            description = string.format("Player: **%s**\nCommand: **%s**", playerName, rawCommand),
            color = 16744192
        })
    end
end, false)

-- Block other Cipher Panel command variants
for _, cmd in ipairs(cipherCommands) do
    RegisterCommand(cmd, function(source, args, rawCommand)
        if source == 0 then return end
        
        local playerName = GetPlayerName(source)
        
        print(string.format("^1[ANTI-CIPHER/BLUM]^7 %s attempted panel command: %s", playerName, rawCommand))
        
        TriggerEvent('anticheat:detection', source, "Blum/Cipher Panel", "PanelCommand", 
            string.format("Command: %s", rawCommand))
            
        if Config.WebhookURL then
            TriggerEvent('anticheat:sendWebhook', {
                title = "🚨 Blum/Cipher Panel Command Detected",
                description = string.format("Player: **%s**\nCommand: **%s**\nAction: Player flagged", playerName, rawCommand),
                color = 16711680
            })
        end
    end, false)
end

-- Monitor for rapid event triggering (Cipher Panel behavior)
local eventCounts = {}
local eventTimeouts = {}

AddEventHandler('anticheat:monitorEvent', function(eventName)
    local source = source
    
    if not eventCounts[source] then
        eventCounts[source] = {}
    end
    
    eventCounts[source][eventName] = (eventCounts[source][eventName] or 0) + 1
    
    -- Reset counter after 5 seconds
    if eventTimeouts[source] and eventTimeouts[source][eventName] then
        Citizen.ClearTimeout(eventTimeouts[source][eventName])
    end
    
    if not eventTimeouts[source] then
        eventTimeouts[source] = {}
    end
    
    eventTimeouts[source][eventName] = SetTimeout(5000, function()
        if eventCounts[source] then
            eventCounts[source][eventName] = 0
        end
    end)
    
    -- Cipher Panel typically spams events rapidly
    if eventCounts[source][eventName] > 10 then
        local playerName = GetPlayerName(source)
        
        print(string.format("^1[ANTI-CIPHER]^7 %s is spamming events (possible Cipher Panel): %s", playerName, eventName))
        
        TriggerEvent('anticheat:detection', source, "Event Spam (Cipher Panel)", "EventSpam", 
            string.format("Event: %s (Count: %d in 5s)", eventName, eventCounts[source][eventName]))
    end
end)

-- Detect unauthorized nui callbacks (Cipher Panel method)
RegisterNetEvent('anticheat:nuiCallback')
AddEventHandler('anticheat:nuiCallback', function(callbackName, data)
    local source = source
    local playerName = GetPlayerName(source)
    
    -- Check for Cipher Panel NUI patterns
    local suspiciousNUI = {
        "cipher",
        "admin_panel",
        "execute_command",
        "inject_",
        "bypass_",
    }
    
    for _, pattern in ipairs(suspiciousNUI) do
        if string.match(string.lower(callbackName), pattern) then
            print(string.format("^1[ANTI-CIPHER]^7 %s triggered suspicious NUI callback: %s", playerName, callbackName))
            
            TriggerEvent('anticheat:detection', source, "Cipher Panel NUI", "CipherNUI", 
                string.format("Callback: %s", callbackName))
            
            if Config.WebhookURL then
                TriggerEvent('anticheat:sendWebhook', {
                    title = "🔴 Suspicious NUI Callback",
                    description = string.format("Player: **%s**\nCallback: **%s**\nData: ```%s```", 
                        playerName, callbackName, json.encode(data)),
                    color = 16711680
                })
            end
            return
        end
    end
end)

-- Scan for Cipher Panel network anomalies
CreateThread(function()
    if not Config.EnableCipherPanelDetection then return end
    
    while true do
        Wait(30000) -- Check every 30 seconds
        
        local players = GetPlayers()
        
        for _, playerId in ipairs(players) do
            local source = tonumber(playerId)
            
            if source then
                -- Check for abnormal network traffic patterns
                local ping = GetPlayerPing(playerId)
            
            if ping and ping > 0 then
                -- Cipher Panel can cause network anomalies
                -- This is a basic check - can be enhanced
                
                if cipherDetections[source] and cipherDetections[source] > 0 then
                    -- Player already flagged, monitor closely
                    if Config.Debug then
                        local playerName = GetPlayerName(playerId)
                        if playerName then
                            print(string.format("^3[ANTI-CIPHER]^7 Monitoring flagged player: %s (Detections: %d)", 
                                playerName, cipherDetections[source]))
                        end
                    end
                end
            end
            end
        end
    end
end)

-- Hook into existing detection system
RegisterNetEvent('anticheat:cipherCheck')
AddEventHandler('anticheat:cipherCheck', function(method, data)
    local source = source
    local playerName = GetPlayerName(source)
    
    print(string.format("^1[ANTI-CIPHER]^7 Cipher Panel activity detected from %s: %s", playerName, method))
    
    TriggerEvent('anticheat:detection', source, "Cipher Panel Activity", "CipherActivity", 
        string.format("Method: %s, Data: %s", method, json.encode(data)))
end)

-- Monitor for DLL injection patterns (common Cipher Panel technique)
RegisterNetEvent('anticheat:dllInjection')
AddEventHandler('anticheat:dllInjection', function(dllName)
    local source = source
    local playerName = GetPlayerName(source)
    
    local suspiciousDLLs = {
        "cipher",
        "panel",
        "inject",
        "hook",
        "cheat",
    }
    
    for _, pattern in ipairs(suspiciousDLLs) do
        if string.match(string.lower(dllName), pattern) then
            print(string.format("^1[ANTI-CIPHER]^7 Suspicious DLL detected from %s: %s", playerName, dllName))
            
            TriggerEvent('anticheat:detection', source, "DLL Injection (Cipher Panel)", "DLLInjection", 
                string.format("DLL: %s", dllName))
            return
        end
    end
end)

print("^2[Anti-Cheat]^7 Cipher Panel detection system loaded!")
