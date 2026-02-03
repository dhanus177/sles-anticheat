-- Enhanced client-side monitoring (runs on player's FiveM client)
-- This is LIMITED but better than nothing

local violations = 0
local suspiciousActivity = {}

-- Monitor for super jump
CreateThread(function()
    while true do
        Wait(1000)
        
        local ped = PlayerPedId()
        
        if IsPedJumping(ped) then
            local startHeight = GetEntityCoords(ped).z
            
            Wait(500)
            
            if IsPedJumping(ped) or IsPedInParachuteFreeFall(ped) then
                local currentHeight = GetEntityCoords(ped).z
                local jumpHeight = currentHeight - startHeight
                
                if jumpHeight > 5.0 then
                    TriggerServerEvent('anticheat:jumpCheck', jumpHeight)
                end
            end
        end
    end
end)

-- Monitor weapon firing for aimbot detection
CreateThread(function()
    while true do
        Wait(0)
        
        local ped = PlayerPedId()
        
        if IsPedShooting(ped) then
            TriggerServerEvent('anticheat:weaponFired')
            
            -- Check if hit was headshot
            local targetPed, targetBone = GetPedLastDamageBone(ped)
            if targetBone == 31086 then -- Head bone
                TriggerServerEvent('anticheat:shotFired', true, targetPed)
            else
                TriggerServerEvent('anticheat:shotFired', false, targetPed)
            end
        end
    end
end)

-- Monitor ammo for infinite ammo detection
local lastAmmoCheck = {}

CreateThread(function()
    while true do
        Wait(2000)
        
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)
        
        if weapon and weapon ~= GetHashKey("WEAPON_UNARMED") then
            local _, ammo = GetAmmoInClip(ped, weapon)
            
            if lastAmmoCheck[weapon] and ammo > lastAmmoCheck[weapon] + 10 then
                -- Ammo increased significantly without reloading
                TriggerServerEvent('anticheat:ammoCheck', weapon, ammo)
            end
            
            lastAmmoCheck[weapon] = ammo
        end
    end
end)

-- Monitor for noclip/fly
CreateThread(function()
    while true do
        Wait(5000)
        
        local ped = PlayerPedId()
        
        if not IsPedInAnyVehicle(ped, false) then
            local coords = GetEntityCoords(ped)
            local _, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
            
            local heightAboveGround = coords.z - groundZ
            
            if heightAboveGround > 10.0 and not IsPedFalling(ped) and not IsPedInParachuteFreeFall(ped) then
                -- Possibly flying/noclip
                violations = violations + 1
                
                if violations > 3 then
                    -- Don't report yet, server will detect this
                    violations = 0
                end
            else
                violations = math.max(0, violations - 1)
            end
        end
    end
end)

-- Block common mod menu keys
CreateThread(function()
    while true do
        Wait(0)
        
        -- Block common mod menu hotkeys
        DisableControlAction(0, 121, true) -- INSERT key
        DisableControlAction(0, 322, true) -- ESC in menu
        
        -- Detect if player pressed mod menu keys
        if IsDisabledControlJustPressed(0, 121) then
            TriggerServerEvent('anticheat:suspiciousKey', 121)
        end
    end
end)

-- Monitor resource injection attempts
CreateThread(function()
    while true do
        Wait(30000)
        
        -- Check for suspicious resources
        local resources = {}
        for i = 0, GetNumResources() - 1 do
            local resource = GetResourceByFindIndex(i)
            table.insert(resources, resource)
        end
        
        -- Send to server for analysis
        TriggerServerEvent('anticheat:resourceList', resources)
    end
end)

-- Anti-tamper: Prevent disabling this resource
AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Resource is being stopped - notify server
        TriggerServerEvent('anticheat:resourceStopped')
    end
end)

-- Heartbeat to prove client is running anti-cheat
CreateThread(function()
    while true do
        Wait(30000)
        TriggerServerEvent('anticheat:heartbeat')
    end
end)

print("^2[ANTI-CHEAT]^7 Client monitoring active")
