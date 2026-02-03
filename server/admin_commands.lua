-- Advanced Admin Commands and Management

-- Spectate player
RegisterCommand('acspectate', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Usage: /acspectate <player_id>"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Invalid player id"}
        })
        return
    end
    if not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Player not found"}
        })
        return
    end
    
    TriggerClientEvent('anticheat:startSpectate', source, targetId)
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTI-CHEAT]", "Spectating " .. GetPlayerName(targetId)}
    })
end, false)

-- Stop spectating
RegisterCommand('acstopspectate', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    TriggerClientEvent('anticheat:stopSpectate', source)
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTI-CHEAT]", "Stopped spectating"}
    })
end, false)

-- Freeze player
RegisterCommand('acfreeze', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Usage: /acfreeze <player_id>"}
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
    
    TriggerClientEvent('anticheat:freeze', targetId, true)
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTI-CHEAT]", "Frozen " .. GetPlayerName(targetId)}
    })
end, false)

-- Unfreeze player
RegisterCommand('acunfreeze', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Usage: /acunfreeze <player_id>"}
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
    
    TriggerClientEvent('anticheat:freeze', targetId, false)
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTI-CHEAT]", "Unfrozen " .. GetPlayerName(targetId)}
    })
end, false)

-- Teleport to player
RegisterCommand('acgoto', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Usage: /acgoto <player_id>"}
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
    
    local targetPed = GetPlayerPed(targetId)
    local targetCoords = GetEntityCoords(targetPed)
    
    SetEntityCoords(GetPlayerPed(source), targetCoords.x, targetCoords.y, targetCoords.z)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTI-CHEAT]", "Teleported to " .. GetPlayerName(targetId)}
    })
end, false)

-- Bring player
RegisterCommand('acbring', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Usage: /acbring <player_id>"}
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
    
    local adminPed = GetPlayerPed(source)
    local adminCoords = GetEntityCoords(adminPed)
    
    SetEntityCoords(GetPlayerPed(targetId), adminCoords.x, adminCoords.y, adminCoords.z)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTI-CHEAT]", "Brought " .. GetPlayerName(targetId)}
    })
end, false)

-- Warn player
RegisterCommand('acwarn', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 2 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Usage: /acwarn <player_id> <reason>"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    
    if not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Player not found"}
        })
        return
    end
    
    local identifier = GetPlayerIdentifiers(targetId)[1]
    if PlayerStats and PlayerStats[identifier] then
        PlayerStats[identifier].warnings = (PlayerStats[identifier].warnings or 0) + 1
        SavePlayerStats()
    end
    
    TriggerClientEvent('chat:addMessage', targetId, {
        args = {"^3[WARNING]", reason}
    })
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTI-CHEAT]", "Warned " .. GetPlayerName(targetId)}
    })
    
    if Config.EnableWebhook then
        SendWebhook("⚠️ Player Warned", string.format(
            "**Admin:** %s\n**Player:** %s\n**Reason:** %s",
            GetPlayerName(source), GetPlayerName(targetId), reason
        ))
    end
end, false)

-- Kick with reason
RegisterCommand('ackick', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 2 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Usage: /ackick <player_id> <reason>"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    
    if not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "Player not found"}
        })
        return
    end
    
    local identifier = GetPlayerIdentifiers(targetId)[1]
    if PlayerStats and PlayerStats[identifier] then
        PlayerStats[identifier].kicks = (PlayerStats[identifier].kicks or 0) + 1
        SavePlayerStats()
    end
    
    DropPlayer(targetId, "Kicked by admin: " .. reason)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTI-CHEAT]", "Kicked " .. GetPlayerName(targetId)}
    })
    
    if Config.EnableWebhook then
        SendWebhook("👢 Player Kicked", string.format(
            "**Admin:** %s\n**Player:** %s\n**Reason:** %s",
            GetPlayerName(source), GetPlayerName(targetId), reason
        ))
    end
end, false)

-- List online players with stats
RegisterCommand('aclist', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ONLINE PLAYERS]", string.format("%d players", #GetPlayers())}
    })
    
    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        local name = GetPlayerName(pid)
        local identifier = GetPlayerIdentifiers(pid)[1]
        local stats = PlayerStats and PlayerStats[identifier]
        
        if stats then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"", string.format("ID:%d %s [Rep:%d | %s]", 
                    pid, name, stats.reputationScore, stats.trustLevel)}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"", string.format("ID:%d %s", pid, name)}
            })
        end
    end
end, false)

-- View recent detections
RegisterCommand('acdetections', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[RECENT DETECTIONS]", "Last 10 detections"}
    })
    
    -- This would show recent detection log
    -- Implementation depends on your logging system
end, false)

-- List online admins
RegisterCommand('acadmins', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    local adminCount = 0
    
    if source == 0 then
        print("^2[ONLINE ADMINS]^7")
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^2[ONLINE ADMINS]", "Currently online administrators"}
        })
    end
    
    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        if IsPlayerAceAllowed(pid, Config.AdminAce) then
            adminCount = adminCount + 1
            local name = GetPlayerName(pid)
            local identifiers = GetPlayerIdentifiers(pid)
            local license = "Unknown"
            local discord = "Unknown"
            
            for _, id in ipairs(identifiers) do
                if string.match(id, "license:") then
                    license = id
                elseif string.match(id, "discord:") then
                    discord = id
                end
            end
            
            if source == 0 then
                print(string.format("  ID:%d %s | %s | %s", pid, name, license, discord))
            else
                TriggerClientEvent('chat:addMessage', source, {
                    args = {"", string.format("^3ID:%d^7 %s", pid, name)}
                })
                TriggerClientEvent('chat:addMessage', source, {
                    args = {"", string.format("  License: ^2%s^7", license)}
                })
                TriggerClientEvent('chat:addMessage', source, {
                    args = {"", string.format("  Discord: ^2%s^7", discord)}
                })
            end
        end
    end
    
    if adminCount == 0 then
        if source == 0 then
            print("^3No admins currently online^7")
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^3[ANTI-CHEAT]", "No admins currently online"}
            })
        end
    else
        if source == 0 then
            print(string.format("^2Total: %d admin(s) online^7", adminCount))
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^2[ANTI-CHEAT]", string.format("Total: %d admin(s) online", adminCount)}
            })
        end
    end
end, false)

-- Unban regular ban
RegisterCommand('acunban', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 1 then
        if source == 0 then
            print("^1[ANTI-CHEAT]^7 Usage: acunban <identifier>")
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^1[ANTI-CHEAT]", "Usage: /acunban <identifier>"}
            })
        end
        return
    end
    
    local identifier = args[1]
    local success = RemoveBan(identifier)
    
    if success then
        if source == 0 then
            print(string.format("^2[ANTI-CHEAT]^7 Player unbanned successfully: %s", identifier))
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^2[ANTI-CHEAT]", "Player unbanned successfully: " .. identifier}
            })
        end
        
        if Config.EnableWebhook then
            SendWebhook("✅ Player Unbanned", string.format(
                "**Admin:** %s\n**Identifier:** %s",
                source == 0 and "Console" or GetPlayerName(source), identifier
            ))
        end
    else
        if source == 0 then
            print("^1[ANTI-CHEAT]^7 Identifier not found in ban list")
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^1[ANTI-CHEAT]", "Identifier not found in ban list"}
            })
        end
    end
end, false)

-- Unban HWID ban
RegisterCommand('acunbanhwid', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-CHEAT]", "You don't have permission to use this command"}
        })
        return
    end
    
    if #args < 1 then
        if source == 0 then
            print("^1[ANTI-CHEAT]^7 Usage: acunbanhwid <hwid>")
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^1[ANTI-CHEAT]", "Usage: /acunbanhwid <hwid>"}
            })
        end
        return
    end
    
    local hwid = args[1]
    local success = RemoveHWIDBan(hwid)
    
    if success then
        if source == 0 then
            print(string.format("^2[ANTI-CHEAT]^7 HWID unbanned successfully: %s", hwid))
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^2[ANTI-CHEAT]", "HWID unbanned successfully: " .. hwid}
            })
        end
        
        if Config.EnableWebhook then
            SendWebhook("✅ HWID Unbanned", string.format(
                "**Admin:** %s\n**HWID:** %s",
                source == 0 and "Console" or GetPlayerName(source), hwid
            ))
        end
    else
        if source == 0 then
            print("^1[ANTI-CHEAT]^7 HWID not found in ban list")
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^1[ANTI-CHEAT]", "HWID not found in ban list"}
            })
        end
    end
end, false)

print("^2[ANTI-CHEAT]^7 Admin commands loaded")
