-- Client-side process checking (limited on FiveM)
CreateThread(function()
    while true do
        Wait(Config.ClientCheckInterval)
        
        -- This is limited - FiveM doesn't have access to Windows processes
        -- But we can check for known executor resources
        
        local suspiciousFound = false
        
        -- Check loaded resources
        for i = 0, GetNumResources() - 1 do
            local resourceName = GetResourceByFindIndex(i)
            
            for _, suspicious in ipairs(CheatDatabase.SuspiciousResources) do
                if string.find(string.lower(resourceName), string.lower(suspicious)) then
                    suspiciousFound = true
                    TriggerServerEvent('anticheat:suspiciousResource', resourceName)
                    break
                end
            end
        end
    end
end)

-- Report suspicious resources
RegisterNetEvent('anticheat:suspiciousResource')
AddEventHandler('anticheat:suspiciousResource', function(resourceName)
    -- Server will handle this
end)
