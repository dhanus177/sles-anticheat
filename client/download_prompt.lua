-- Client-Side Download Prompt Handler
-- Opens browser download link for ClientScanner

local hasShownDownload = false

-- Handle download prompt from server
RegisterNetEvent('anticheat:openDownload')
AddEventHandler('anticheat:openDownload', function(downloadUrl)
    if not hasShownDownload and downloadUrl then
        hasShownDownload = true
        
        -- Show notification
        SetNotificationTextEntry("STRING")
        AddTextComponentString("~b~Anti-Cheat Protection~w~\n~g~Download ClientScanner for enhanced security\n~y~Check chat for download link")
        DrawNotification(false, false)
        
        -- Open browser with download link (optional - some servers block this)
        -- SendNUIMessage({
        --     type = "openUrl",
        --     url = downloadUrl
        -- })
        
        print("^2[ANTI-CHEAT]^7 Download ClientScanner.exe from: " .. downloadUrl)
    end
end)

-- Show periodic reminder
CreateThread(function()
    while true do
        Wait(600000) -- Every 10 minutes
        
        if not hasShownDownload then
            SetNotificationTextEntry("STRING")
            AddTextComponentString("~y~Tip:~w~ Download ClientScanner.exe for better protection!\nCheck chat for download link")
            DrawNotification(false, false)
        end
    end
end)
