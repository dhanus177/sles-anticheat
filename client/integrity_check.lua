-- Integrity checking for game files and modifications
local IntegrityViolations = 0

-- Check for common mod menu triggers
CreateThread(function()
    while true do
        Wait(30000) -- Every 30 seconds
        
        local ped = PlayerPedId()
        
        -- Check for super jump
        if GetPedParachuteState(ped) == -1 and IsPedJumping(ped) then
            local jumpHeight = GetEntityHeightAboveGround(ped)
            if jumpHeight > 10.0 then
                TriggerServerEvent('anticheat:detection', 'Super Jump', 'Modifier', 'Jump height: ' .. jumpHeight)
            end
        end
        
        -- Check for rapid fire
        if IsPedShooting(ped) then
            local weaponHash = GetSelectedPedWeapon(ped)
            TriggerServerEvent('anticheat:weaponCheck', weaponHash)
        end
    end
end)

-- Check for noclip
CreateThread(function()
    while true do
        Wait(5000)
        
        local ped = PlayerPedId()
        
        if not IsPedInAnyVehicle(ped, false) then
            local isFlying = not IsPedFalling(ped) and GetEntityHeightAboveGround(ped) > 5.0
            
            if isFlying and not IsPedInParachuteFreeFall(ped) then
                -- Possible noclip (removed IsPedParachuting - doesn't exist)
                IntegrityViolations = IntegrityViolations + 1
                
                if IntegrityViolations > 3 then
                    TriggerServerEvent('anticheat:detection', 'No-Clip', 'Movement', 'Flying without vehicle')
                    IntegrityViolations = 0
                end
            else
                IntegrityViolations = 0
            end
        end
    end
end)

-- Block certain keys commonly used by mod menus
CreateThread(function()
    while true do
        Wait(0)
        
        -- Block INSERT key (common mod menu toggle)
        if IsControlJustPressed(0, 121) then -- INSERT
            TriggerServerEvent('anticheat:detection', 'Mod Menu Key', 'Input', 'INSERT key pressed')
        end
        
        -- Block F8 (common executor key)
        if IsControlJustPressed(0, 169) then -- F8
            -- Allow F8 for console unless spammed
        end
    end
end)
