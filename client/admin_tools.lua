-- Client-side admin tools

local isSpectating = false
local spectateTarget = nil
local isFrozen = false

-- Spectate player
RegisterNetEvent('anticheat:startSpectate')
AddEventHandler('anticheat:startSpectate', function(targetId)
    if isSpectating then
        return
    end
    
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    
    if DoesEntityExist(targetPed) then
        isSpectating = true
        spectateTarget = targetId
        
        local playerPed = PlayerPedId()
        SetEntityVisible(playerPed, false, false)
        SetEntityCollision(playerPed, false, false)
        FreezeEntityPosition(playerPed, true)
        
        NetworkSetInSpectatorMode(true, targetPed)
        
        CreateThread(function()
            while isSpectating do
                Wait(0)
                
                -- Update spectate target
                local target = GetPlayerPed(GetPlayerFromServerId(spectateTarget))
                if not DoesEntityExist(target) then
                    TriggerEvent('anticheat:stopSpectate')
                    break
                end
                
                -- Display info
                local targetCoords = GetEntityCoords(target)
                local targetHealth = GetEntityHealth(target)
                local targetArmor = GetPedArmour(target)
                
                SetTextFont(0)
                SetTextProportional(1)
                SetTextScale(0.0, 0.4)
                SetTextDropshadow(0, 0, 0, 0, 255)
                SetTextEdge(1, 0, 0, 0, 255)
                SetTextDropShadow()
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(string.format(
                    "Spectating: ID %d\nHealth: %d | Armor: %d\nCoords: %.1f, %.1f, %.1f",
                    spectateTarget, targetHealth, targetArmor,
                    targetCoords.x, targetCoords.y, targetCoords.z
                ))
                DrawText(0.5, 0.01)
            end
        end)
    end
end)

-- Stop spectating
RegisterNetEvent('anticheat:stopSpectate')
AddEventHandler('anticheat:stopSpectate', function()
    if not isSpectating then
        return
    end
    
    isSpectating = false
    spectateTarget = nil
    
    NetworkSetInSpectatorMode(false, PlayerPedId())
    
    local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, true, false)
    SetEntityCollision(playerPed, true, true)
    FreezeEntityPosition(playerPed, false)
end)

-- Freeze/unfreeze
RegisterNetEvent('anticheat:freeze')
AddEventHandler('anticheat:freeze', function(state)
    isFrozen = state
    local playerPed = PlayerPedId()
    
    FreezeEntityPosition(playerPed, state)
    
    if state then
        SetEntityInvincible(playerPed, true)
    else
        SetEntityInvincible(playerPed, false)
    end
    
    -- Visual feedback
    if state then
        SetNotificationTextEntry("STRING")
        AddTextComponentString("~r~You have been frozen by an admin")
        DrawNotification(false, true)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString("~g~You have been unfrozen")
        DrawNotification(false, true)
    end
end)

-- Display freeze message
CreateThread(function()
    while true do
        Wait(0)
        
        if isFrozen then
            SetTextFont(0)
            SetTextProportional(1)
            SetTextScale(0.0, 0.5)
            SetTextColour(255, 0, 0, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString("~r~FROZEN BY ADMIN")
            DrawText(0.5, 0.45)
        end
    end
end)
