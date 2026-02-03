-- Admin Panel NUI (In-Game GUI)
-- Press F10 to open admin panel

local adminPanelOpen = false
local selectedPlayer = nil
local playerList = {}

-- Register NUI Callback
RegisterNUICallback('closeUI', function(data, cb)
    print("^3[ADMIN-PANEL-CLIENT]^7 Closing panel, releasing cursor...")
    adminPanelOpen = false
    SetNuiFocus(false, false)
    
    -- Ensure cursor is unlocked and controls restored
    SetNuiFocusKeepInput(false)
    DisplayRadar(true)
    
    cb('ok')
end)

RegisterNUICallback('banPlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'ban', data.playerId, data.reason)
    cb('ok')
end)

RegisterNUICallback('kickPlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'kick', data.playerId, data.reason)
    cb('ok')
end)

RegisterNUICallback('warnPlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'warn', data.playerId, data.reason)
    cb('ok')
end)

RegisterNUICallback('freezePlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'freeze', data.playerId)
    cb('ok')
end)

RegisterNUICallback('unfreezePlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'unfreeze', data.playerId)
    cb('ok')
end)

RegisterNUICallback('spectatePlayer', function(data, cb)
    TriggerEvent('anticheat:startSpectate', data.playerId)
    cb('ok')
end)

RegisterNUICallback('stopSpectate', function(data, cb)
    TriggerEvent('anticheat:stopSpectate')
    cb('ok')
end)

RegisterNUICallback('screenshotPlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'screenshot', data.playerId)
    cb('ok')
end)

RegisterNUICallback('gotoPlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'goto', data.playerId)
    cb('ok')
end)

RegisterNUICallback('bringPlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'bring', data.playerId)
    cb('ok')
end)

RegisterNUICallback('refreshPlayers', function(data, cb)
    TriggerServerEvent('anticheat:requestPlayerList')
    cb('ok')
end)

RegisterNUICallback('getPlayerInfo', function(data, cb)
    TriggerServerEvent('anticheat:requestPlayerInfo', data.playerId)
    cb('ok')
end)

RegisterNUICallback('viewBans', function(data, cb)
    TriggerServerEvent('anticheat:requestBanList')
    cb('ok')
end)

RegisterNUICallback('unbanPlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'unban', nil, data.identifier)
    cb('ok')
end)

RegisterNUICallback('banHWIDPlayer', function(data, cb)
    TriggerServerEvent('anticheat:adminAction', 'banhwid', data.playerId, data.reason)
    cb('ok')
end)

RegisterNUICallback('requestRecentDetections', function(data, cb)
    TriggerServerEvent('anticheat:requestRecentDetections')
    cb('ok')
end)

RegisterNUICallback('requestConfig', function(data, cb)
    TriggerServerEvent('anticheat:requestConfig')
    cb('ok')
end)

-- Receive player list from server
RegisterNetEvent('anticheat:receivePlayerList')
AddEventHandler('anticheat:receivePlayerList', function(players)
    SendNUIMessage({
        type = "updatePlayerList",
        players = players
    })
end)

-- Receive player info
RegisterNetEvent('anticheat:receivePlayerInfo')
AddEventHandler('anticheat:receivePlayerInfo', function(info)
    SendNUIMessage({
        type = "updatePlayerInfo",
        info = info
    })
end)

-- Receive ban list
RegisterNetEvent('anticheat:receiveBanList')
AddEventHandler('anticheat:receiveBanList', function(bans)
    SendNUIMessage({
        type = "updateBanList",
        bans = bans
    })
end)

-- Receive detections
RegisterNetEvent('anticheat:receiveDetections')
AddEventHandler('anticheat:receiveDetections', function(detections)
    SendNUIMessage({
        type = "updateDetections",
        detections = detections
    })
end)

-- Receive config
RegisterNetEvent('anticheat:receiveConfig')
AddEventHandler('anticheat:receiveConfig', function(config)
    SendNUIMessage({
        type = "updateConfig",
        config = config
    })
end)

-- Receive system stats
RegisterNetEvent('anticheat:receiveStats')
AddEventHandler('anticheat:receiveStats', function(stats)
    SendNUIMessage({
        type = "updateStats",
        stats = stats
    })
end)

-- Toggle admin panel (F10)
RegisterCommand('acpanel', function()
    if adminPanelOpen then
        -- Toggle close if already open
        print("^3[ADMIN-PANEL-CLIENT]^7 Closing panel via F10...")
        adminPanelOpen = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        DisplayRadar(true)
        SendNUIMessage({ type = "forceClose" })
        print("^3[ADMIN-PANEL-CLIENT]^7 Panel closed, cursor unlocked")
        return
    end

    print("^3[ADMIN-PANEL-CLIENT]^7 F10 pressed, requesting admin access...")
    TriggerServerEvent('anticheat:checkAdmin')
end, false)

RegisterKeyMapping('acpanel', 'Open Anti-Cheat Admin Panel', 'keyboard', 'F10')

-- Server confirms admin status
RegisterNetEvent('anticheat:openPanel')
AddEventHandler('anticheat:openPanel', function()
    print("^2[ADMIN-PANEL-CLIENT]^7 Opening admin panel...")
    adminPanelOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openPanel"
    })
    
    -- Request initial data
    TriggerServerEvent('anticheat:requestPlayerList')
    TriggerServerEvent('anticheat:requestStats')
    TriggerServerEvent('anticheat:requestRecentDetections')
    TriggerServerEvent('anticheat:requestConfig')
    print("^2[ADMIN-PANEL-CLIENT]^7 Panel opened successfully")
end)

-- Force-close panel from server or toggle
RegisterNetEvent('anticheat:closePanel')
AddEventHandler('anticheat:closePanel', function()
    print("^3[ADMIN-PANEL-CLIENT]^7 Panel closed by server, unlocking cursor...")
    adminPanelOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    DisplayRadar(true)
    SendNUIMessage({ type = "forceClose" })
end)

-- Notification system
RegisterNetEvent('anticheat:notify')
AddEventHandler('anticheat:notify', function(message, type)
    SendNUIMessage({
        type = "notification",
        message = message,
        notifType = type or "info"
    })
end)

-- Admin notification for detections
RegisterNetEvent('anticheat:adminNotification')
AddEventHandler('anticheat:adminNotification', function(data)
    -- Send to NUI for display
    SendNUIMessage({
        type = "adminAlert",
        data = data
    })
    
    -- Play alert sound
    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
end)

-- Auto-refresh player list every 5 seconds when panel is open
CreateThread(function()
    while true do
        Wait(5000)
        if adminPanelOpen then
            TriggerServerEvent('anticheat:requestPlayerList')
        end
    end
end)

-- ESC key handler to ensure cursor is unlocked
CreateThread(function()
    while true do
        Wait(0)
        if adminPanelOpen then
            -- Disable controls while panel is open
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1
            
            -- ESC to close
            if IsControlJustReleased(0, 322) or IsControlJustReleased(0, 177) then -- ESC or BACKSPACE
                print("^3[ADMIN-PANEL-CLIENT]^7 ESC pressed, closing panel...")
                adminPanelOpen = false
                SetNuiFocus(false, false)
                SetNuiFocusKeepInput(false)
                DisplayRadar(true)
                SendNUIMessage({ type = "forceClose" })
                print("^3[ADMIN-PANEL-CLIENT]^7 Panel closed via ESC, cursor unlocked")
            end
        else
            Wait(500) -- Save resources when panel is closed
        end
    end
end)
