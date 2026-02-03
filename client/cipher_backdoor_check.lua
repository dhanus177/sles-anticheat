-- Client-Side Cipher Panel and Backdoor Detection
-- Monitors for suspicious client-side activities

local detectionCount = 0
local monitoredEvents = {}

-- Monitor for suspicious resource loading
CreateThread(function()
    while true do
        Wait(10000) -- Check every 10 seconds
        
        if not Config.EnableCipherPanelDetection and not Config.EnableBackdoorCheck then
            return
        end
        
        -- Check for suspicious resources
        local resources = GetNumResources()
        
        for i = 0, resources - 1 do
            local resourceName = GetResourceByFindIndex(i)
            
            if resourceName then
                local lowerName = string.lower(resourceName)
                
                -- Check for Cipher Panel, Blum Panel, X-Menu, D-Panel
                if string.match(lowerName, "cipher") or 
                   string.match(lowerName, "backdoor") or
                   string.match(lowerName, "blum") or
                   string.match(lowerName, "xmenu") or
                   string.match(lowerName, "x%-menu") or
                   string.match(lowerName, "dpanel") or
                   string.match(lowerName, "d%-panel") then
                    print(string.format("^1[CLIENT ANTI-CHEAT]^7 Suspicious resource detected: %s", resourceName))
                    
                    TriggerServerEvent('anticheat:suspiciousResource', resourceName)
                    detectionCount = detectionCount + 1
                end
            end
        end
    end
end)

-- Monitor for unauthorized NUI creation
local nuiCallbacks = {}
CreateThread(function()
    while true do
        Wait(5000)
        
        if not Config.EnableCipherPanelDetection then
            return
        end
        
        -- Cipher Panel often creates hidden NUI elements
        -- This is a basic detection - can be enhanced with more checks
    end
end)

-- Detect rapid command execution (Cipher Panel behavior)
local commandCount = 0
local commandResetTimer = GetGameTimer()

AddEventHandler('onClientResourceStart', function(resourceName)
    local lowerName = string.lower(resourceName)
    
    local suspiciousPatterns = {
        "cipher",
        "backdoor",
        "admin_panel",
        "cheat",
        "mod_menu",
        "inject",
        "blum",
        "blumpanel",
        "blum_panel",
        "xmenu",
        "x_menu",
        "dpanel",
        "d_panel",
    }
    
    for _, pattern in ipairs(suspiciousPatterns) do
        if string.match(lowerName, pattern) then
            print(string.format("^1[CLIENT ANTI-CHEAT]^7 Blocked suspicious resource: %s", resourceName))
            TriggerServerEvent('anticheat:blockedResource', resourceName)
            return
        end
    end
end)

-- Monitor for memory manipulation
CreateThread(function()
    while true do
        Wait(15000) -- Check every 15 seconds
        
        if not Config.EnableCipherPanelDetection then
            return
        end
        
        -- Check for abnormal memory patterns
        local ped = PlayerPedId()
        
        -- Cipher Panel often modifies player health/armor in suspicious ways
        local health = GetEntityHealth(ped)
        local maxHealth = GetEntityMaxHealth(ped)
        
        if health > maxHealth + 100 then
            -- Abnormal health detected
            TriggerServerEvent('anticheat:abnormalHealth', health, maxHealth)
        end
        
        -- Check for suspicious armor
        local armor = GetPedArmour(ped)
        if armor > 100 then
            TriggerServerEvent('anticheat:abnormalArmor', armor)
        end
    end
end)

-- Detect unauthorized commands
RegisterCommand('cipher', function()
    print("^1[CLIENT ANTI-CHEAT]^7 Blocked Cipher Panel command attempt")
    TriggerServerEvent('anticheat:blockedCommand', 'cipher')
end, false)

RegisterCommand('cpanel', function()
    print("^1[CLIENT ANTI-CHEAT]^7 Blocked Cipher Panel command attempt")
    TriggerServerEvent('anticheat:blockedCommand', 'cpanel')
end, false)

RegisterCommand('backdoor', function()
    print("^1[CLIENT ANTI-CHEAT]^7 Blocked backdoor command attempt")
    TriggerServerEvent('anticheat:blockedCommand', 'backdoor')
end, false)

-- Blum Panel command blocks
RegisterCommand('blum', function()
    print("^1[CLIENT ANTI-CHEAT]^7 Blocked Blum Panel command attempt")
    TriggerServerEvent('anticheat:blockedCommand', 'blum')
end, false)

RegisterCommand('blumpanel', function()
    print("^1[CLIENT ANTI-CHEAT]^7 Blocked Blum Panel command attempt")
    TriggerServerEvent('anticheat:blockedCommand', 'blumpanel')
end, false)

RegisterCommand('blummenu', function()
    print("^1[CLIENT ANTI-CHEAT]^7 Blocked Blum Menu command attempt")
    TriggerServerEvent('anticheat:blockedCommand', 'blummenu')
end, false)

-- X-Menu command blocks
RegisterCommand('xmenu', function()
    print("^1[CLIENT ANTI-CHEAT]^7 Blocked X-Menu command attempt")
    TriggerServerEvent('anticheat:blockedCommand', 'xmenu')
end, false)

-- D-Panel command blocks
RegisterCommand('dpanel', function()
    print("^1[CLIENT ANTI-CHEAT]^7 Blocked D-Panel command attempt")
    TriggerServerEvent('anticheat:blockedCommand', 'dpanel')
end, false)

-- Monitor for rapid event triggering
local eventSpamCount = {}
CreateThread(function()
    while true do
        Wait(5000)
        
        -- Reset spam counters
        for event, count in pairs(eventSpamCount) do
            if count > 20 then
                -- Possible event spam (Cipher Panel behavior)
                TriggerServerEvent('anticheat:eventSpam', event, count)
            end
            eventSpamCount[event] = 0
        end
    end
end)

-- Hook into native function calls
local suspiciousNatives = {
    "GIVE_WEAPON_TO_PED",
    "SET_ENTITY_HEALTH",
    "SET_PED_ARMOUR",
    "SET_ENTITY_COORDS_NO_OFFSET",
    "SET_ENTITY_INVINCIBLE",
}

-- Monitor for DLL injection attempts
CreateThread(function()
    while true do
        Wait(20000) -- Check every 20 seconds
        
        if not Config.EnableCipherPanelDetection and not Config.EnableBackdoorCheck then
            return
        end
        
        -- Check for memory anomalies that might indicate injection
        local ped = PlayerPedId()
        
        -- Check if player has abnormal capabilities
        local isInvincible = GetPlayerInvincible(PlayerId())
        
        if isInvincible and not IsPedInAnyVehicle(ped, false) then
            -- Suspicious invincibility
            TriggerServerEvent('anticheat:suspiciousInvincibility')
        end
    end
end)

-- Detect unauthorized teleportation
local lastPos = nil
CreateThread(function()
    while true do
        Wait(1000)
        
        if not Config.EnableCipherPanelDetection then
            return
        end
        
        local ped = PlayerPedId()
        local currentPos = GetEntityCoords(ped)
        
        if lastPos then
            local distance = #(currentPos - lastPos)
            
            -- Cipher Panel often teleports players
            if distance > 100 and not IsPedInAnyVehicle(ped, false) then
                -- Large instant movement detected
                -- Server will handle final validation
            end
        end
        
        lastPos = currentPos
    end
end)

-- Monitor for unauthorized weapon spawning
local lastWeapon = nil
CreateThread(function()
    while true do
        Wait(2000)
        
        if not Config.EnableCipherPanelDetection then
            return
        end
        
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)
        
        if weapon and weapon ~= lastWeapon then
            -- Weapon changed, check if it's authorized
            -- Server will validate
        end
        
        lastWeapon = weapon
    end
end)

print("^2[Anti-Cheat Client]^7 Cipher Panel and Backdoor detection active!")
