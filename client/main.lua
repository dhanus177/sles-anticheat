print("^2[ANTI-CHEAT]^7 Client-side monitoring active")

-- Send client detection to server
RegisterNetEvent('anticheat:detection')
AddEventHandler('anticheat:detection', function(reason, detectionType, details)
    -- Server handles the detection
end)

-- Monitor vehicle spawning
CreateThread(function()
    while true do
        Wait(1000)
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            local vehicleHash = GetEntityModel(vehicle)
            local vehicleName = GetDisplayNameFromHashKey(vehicleHash)
            TriggerServerEvent('anticheat:vehicleSpawned', vehicleName)
        end
    end
end)

-- Monitor weapon spawning
local lastWeapon = 0
CreateThread(function()
    while true do
        Wait(2000)
        
        local ped = PlayerPedId()
        local currentWeapon = GetSelectedPedWeapon(ped)
        
        if currentWeapon ~= 0 and currentWeapon ~= lastWeapon then
            lastWeapon = currentWeapon
            -- Send weapon hash to server for checking
            TriggerServerEvent('anticheat:weaponSpawned', tostring(currentWeapon))
        end
    end
end)

-- Disable certain debug features
CreateThread(function()
    while true do
        Wait(0)
        
        -- Disable some debug options
        SetPlayerInvincible(PlayerId(), false)
    end
end)
