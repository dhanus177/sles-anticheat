print("^2[ANTI-CHEAT]^7 Server-side anti-cheat loaded")
print("^2[ANTI-CHEAT]^7 Monitoring for cheats and exploits...")

-- Client scanner reports
local ClientReports = {}
local PlayerScannerStatus = {} -- Track which players have scanner running
local PlayerScannerHistory = {} -- Track if scanner was ever running for each player

-- HTTP endpoint for client scanner reports
SetHttpHandler(function(req, res)
    if req.path == '/anticheat/detections' and req.method == 'GET' then
        if not Config.EnableDashboardEndpoint then
            res.writeHead(404)
            res.send("Not found")
            return
        end

        if Config.DashboardApiKey and Config.DashboardApiKey ~= "" then
            local headers = req.headers or {}
            local apiKey = headers["x-api-key"] or headers["X-API-Key"]
            if apiKey ~= Config.DashboardApiKey then
                res.writeHead(401)
                res.send("Unauthorized")
                return
            end
        end

        local payload = json.encode(GetRecentDetections and GetRecentDetections() or {})
        res.writeHead(200, { ["Content-Type"] = "application/json" })
        res.send(payload)
        return
    end

    if req.path == '/anticheat-client' and req.method == 'POST' then
        local data = json.decode(req.body)
        
        if data and data.type then
            -- Handle heartbeat (scanner still running)
            if data.type == "Heartbeat" then
                -- Find player by machine name
                local players = GetPlayers()
                for _, playerId in ipairs(players) do
                    local identifier = GetPlayerIdentifiers(playerId)[1]
                    PlayerScannerStatus[identifier] = {
                        lastSeen = os.time(),
                        machineName = data.machineName,
                        userName = data.userName
                    }
                    -- Mark that this player HAS had scanner running
                    PlayerScannerHistory[identifier] = true
                end
                
                res.writeHead(200, { ["Content-Type"] = "application/json" })
                res.send(json.encode({ success = true }))
                return
            end

            -- Handle watchdog/tamper alerts
            if data.type == "Watchdog" then
                print(string.format("^1[CLIENT-SCANNER]^7 Watchdog alert: %s (%s/%s)",
                    data.reason or "Unknown", data.machineName or "Unknown", data.userName or "Unknown"))

                if Config.EnableWebhook then
                    SendWebhook("⚠️ Client Scanner Watchdog", string.format(
                        "**Reason:** %s\n**Machine:** %s\n**User:** %s",
                        data.reason or "Unknown",
                        data.machineName or "Unknown",
                        data.userName or "Unknown"
                    ))
                end

                res.writeHead(200, { ["Content-Type"] = "application/json" })
                res.send(json.encode({ success = true }))
                return
            end
            
            -- Handle cheat detection
            if data.type == "ProcessDetection" then
                print(string.format("^3[CLIENT-SCANNER]^7 Detection: %s - %s", data.type, data.details))
                
                -- Find player by machine name
                local players = GetPlayers()
                for _, playerId in ipairs(players) do
                    local playerName = GetPlayerName(playerId)
                    local identifier = GetPlayerIdentifiers(playerId)[1]
                    
                    print(string.format("^1[ANTI-CHEAT]^7 Kicking %s for client detection: %s", playerName, data.details))
                    
                    if Config.AutoBan then
                        AddBan(identifier, playerName, "Client Scanner: " .. data.details, data.type)
                    end
                    
                    DropPlayer(playerId, "🛡️ Anti-Cheat: Detected cheat software - " .. data.details)
                    
                    -- Send webhook
                    if Config.EnableWebhook then
                        SendWebhook("🖥️ Client Scanner Detection", string.format(
                            "**Player:** %s\n**Type:** %s\n**Details:** %s\n**Machine:** %s",
                            playerName, data.type, data.details, data.machineName or "Unknown"
                        ))
                    end
                end
                
                res.writeHead(200, { ["Content-Type"] = "application/json" })
                res.send(json.encode({ success = true, action = "kicked" }))
                return
            end
        end
        
        res.writeHead(400)
        res.send("Invalid request")
    else
        res.writeHead(404)
        res.send("Not found")
    end
end)

-- Notify player on join about client scanner
AddEventHandler('playerJoining', function()
    local source = source
    
    if Config.ShowDownloadPrompt then
        SetTimeout(10000, function() -- Wait 10 seconds after join
            if Config.ClientScannerUrl then
                TriggerClientEvent('chat:addMessage', source, {
                    args = {"^2[ANTI-CHEAT]", "^7=================================="}
                })
                TriggerClientEvent('chat:addMessage', source, {
                    args = {"^2[ANTI-CHEAT]", "^7Enhanced Protection Available!"}
                })
                TriggerClientEvent('chat:addMessage', source, {
                    args = {"^3[ANTI-CHEAT]", "^7Download ClientScanner for extra security:"}
                })
                TriggerClientEvent('chat:addMessage', source, {
                    args = {"^6[DOWNLOAD]", Config.ClientScannerUrl}
                })
                if Config.KickOnScannerClose then
                    TriggerClientEvent('chat:addMessage', source, {
                        args = {"^1[WARNING]", "^7Do NOT close scanner while playing!"}
                    })
                end
                TriggerClientEvent('chat:addMessage', source, {
                    args = {"^2[ANTI-CHEAT]", "^7=================================="}
                })
                
                -- Open download URL in player's browser
                TriggerClientEvent('anticheat:openDownload', source, Config.ClientScannerUrl)
            end
        end)
    end
end)

-- Clean up on player disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    
    -- Clean up scanner tracking
    if PlayerScannerStatus[identifier] then
        PlayerScannerStatus[identifier] = nil
    end
    if PlayerScannerHistory[identifier] then
        PlayerScannerHistory[identifier] = nil
    end
end)

-- Check scanner status and notify players
CreateThread(function()
    while true do
        Wait(Config.DownloadPromptInterval and (Config.DownloadPromptInterval * 1000) or 300000) -- Check periodically
        
        if Config.RequireClientScanner or Config.RecommendClientScanner then
            local players = GetPlayers()
            for _, playerId in ipairs(players) do
                local identifier = GetPlayerIdentifiers(playerId)[1]
                local scannerStatus = PlayerScannerStatus[identifier]
                
                if not scannerStatus or (os.time() - scannerStatus.lastSeen) > Config.ScannerHeartbeatTimeout then
                    -- Check if scanner was running before (player closed it)
                    if PlayerScannerHistory[identifier] and Config.KickOnScannerClose then
                        -- Scanner WAS running but now stopped - player closed it!
                        print(string.format("^1[ANTI-CHEAT]^7 %s closed ClientScanner - Kicking", GetPlayerName(playerId)))
                        DropPlayer(playerId, "🛡️ Anti-Cheat: ClientScanner closed\nKeep scanner running while playing!")
                        
                        if Config.EnableWebhook then
                            SendWebhook("⚠️ Scanner Closed", string.format(
                                "**Player:** %s\n**Action:** Kicked for closing scanner\n**Identifier:** %s",
                                GetPlayerName(playerId), identifier
                            ))
                        end
                    else
                        -- Scanner never ran - show prompts
                        if Config.RequireClientScanner then
                            -- Kick if mandatory
                            DropPlayer(playerId, "🛡️ Anti-Cheat: ClientScanner.exe required\nDownload: " .. (Config.ClientScannerUrl or "Contact server admin"))
                        elseif Config.RecommendClientScanner then
                            -- Just warn if optional
                            TriggerClientEvent('chat:addMessage', playerId, {
                                args = {"^3[ANTI-CHEAT]", "^7💡 Tip: Run ClientScanner.exe for better protection"}
                            })
                            TriggerClientEvent('chat:addMessage', playerId, {
                                args = {"^6[DOWNLOAD]", Config.ClientScannerUrl or "Contact admin"}
                            })
                        end
                    end
                end
            end
        end
    end
end)

-- Handle blocked command reports from client
RegisterNetEvent('anticheat:blockedCommand')
AddEventHandler('anticheat:blockedCommand', function(commandName)
    local source = source
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    
    print(string.format("^1[ANTI-CHEAT]^7 %s attempted blocked command: /%s", playerName, commandName))
    
    -- Immediate detection for panel commands
    TriggerEvent('anticheat:detection', source, "Blum/Cipher Panel Command", "PanelCommand", 
        string.format("Command: /%s", commandName))
    
    if Config.EnableWebhook then
        SendWebhook("🚨 Blocked Panel Command", string.format(
            "**Player:** %s\n**Command:** /%s\n**Action:** Flagged for cheating\n**Identifier:** %s",
            playerName, commandName, identifier
        ))
    end
end)

-- Admin commands
RegisterCommand('acban', function(source, args)
    -- Check if player has permission (source == 0 is console)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 2 then
        if source == 0 then
            print("Usage: acban <player_id> <reason>")
        else
            TriggerClientEvent('chat:addMessage', source, {args = {"^1[ANTI-CHEAT]", "Usage: /acban <player_id> <reason>"}})
        end
        return
    end
    
    local targetId = tonumber(args[1])
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    
    if GetPlayerName(targetId) then
        local identifier = GetPlayerIdentifiers(targetId)[1]
        local playerName = GetPlayerName(targetId)
        
        AddBan(identifier, playerName, reason, "Manual")
        DropPlayer(targetId, Config.BanMessage .. "\nReason: " .. reason)
        
        if source == 0 then
            print(string.format("[ANTI-CHEAT] Banned %s", playerName))
        else
            TriggerClientEvent('chat:addMessage', source, {args = {"^2[ANTI-CHEAT]", "Banned " .. playerName}})
        end
    end
end, false)

RegisterCommand('acunban', function(source, args)
    -- Check if player has permission (source == 0 is console)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 1 then
        if source == 0 then
            print("Usage: acunban <identifier>")
        else
            TriggerClientEvent('chat:addMessage', source, {args = {"^1[ANTI-CHEAT]", "Usage: /acunban <identifier>"}})
        end
        return
    end
    
    local identifier = args[1]
    
    if RemoveBan(identifier) then
        if source == 0 then
            print("[ANTI-CHEAT] Unbanned " .. identifier)
        else
            TriggerClientEvent('chat:addMessage', source, {args = {"^2[ANTI-CHEAT]", "Unbanned " .. identifier}})
        end
    else
        if source == 0 then
            print("[ANTI-CHEAT] Ban not found")
        else
            TriggerClientEvent('chat:addMessage', source, {args = {"^1[ANTI-CHEAT]", "Ban not found"}})
        end
    end
end, false)

RegisterCommand('acstats', function(source, args)
    -- Check if player has permission (source == 0 is console)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    local playerCount = #GetPlayers()
    local message = string.format("^2[ANTI-CHEAT]^7 Monitoring %d players", playerCount)
    
    if source == 0 then
        print(message)
    else
        TriggerClientEvent('chat:addMessage', source, {args = {message}})
    end
end, false)
