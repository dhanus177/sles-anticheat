-- Anti-Backdoor System
-- Detects and prevents unauthorized backdoor access attempts

local detectedBackdoors = {}
local suspiciousCommands = {}

-- Suspicious event patterns that might indicate backdoors
local backdoorPatterns = {
    "give.*money",
    "give.*item",
    "add.*money",
    "set.*job",
    "admin.*access",
    "bypass.*",
    "inject.*",
    "execute.*",
    "sql.*query",
    "database.*",
    "unlock.*all",
    "spawn.*vehicle",
    "god.*mode",
    "super.*admin",
    "backdoor",
    "exploit",
    "trigger.*server",
    "cheat",
    "hack",
    "mod_menu",
    "menu_mod",
    "exploit_",
    "_exploit",
    "_backdoor",
    "backdoor_",
    "shell",
    "webshell",
    "panel",
    "admin_panel",
    "hidden_",
    "_hidden",
    "inject_",
    "_inject",
    "malicious",
    "trojan",
    "virus",
    "rootkit",
    "blum",
    "blumpanel",
    "blum.*panel",
    "blum.*menu",
    "x.*menu",
    "d.*panel",
}

-- Protected server events that should never be triggered from client
local protectedServerEvents = {
    "_cfx_internal",
    "esx:giveInventoryItem",
    "esx:giveMoney",
    "esx_policejob:giveWeapon",
    "esx_ambulancejob:revive",
    "esx:setJob",
    "qb-banking:server:TransferMoney",
    "qb-management:server:withdrawMoney",
    "qb-phone:server:GiveCash",
    "qb-inventory:server:AddItem",
    "qb-vehicleshop:server:buyVehicle",
}

-- Monitor for suspicious resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if not Config.EnableBackdoorCheck then return end
    
    local lowerName = string.lower(resourceName)
    
    -- Check whitelist first (skip if whitelisted)
    if Config.WhitelistedResources then
        for _, whitelisted in ipairs(Config.WhitelistedResources) do
            if string.lower(resourceName) == string.lower(whitelisted) then
                return -- Allow whitelisted resources
            end
        end
    end
    
    -- Check for backdoor indicators in resource names
    for _, pattern in ipairs(backdoorPatterns) do
        if string.match(lowerName, pattern) then
            print(string.format("^1[ANTI-BACKDOOR]^7 Suspicious resource detected: %s (Pattern: %s)", resourceName, pattern))
            
            if Config.WebhookURL and Config.EnableWebhook then
                TriggerEvent('anticheat:sendWebhook', {
                    title = "🚨 Suspicious Resource Blocked",
                    description = string.format("**Resource:** %s\n**Pattern:** %s\n**Action:** Stopped immediately\n**Reason:** Backdoor pattern detected in resource name", resourceName, pattern),
                    color = 16711680
                })
            end
            
            -- Stop the suspicious resource immediately
            if Config.AutoStopSuspiciousResources then
                StopResource(resourceName)
                print(string.format("^1[ANTI-BACKDOOR]^7 Stopped suspicious resource: %s", resourceName))
            end
            
            -- Log to file for audit trail
            if Config.LogBlockedResources then
                local logEntry = string.format("[%s] BLOCKED RESOURCE: %s (Pattern: %s)\n", os.date("%Y-%m-%d %H:%M:%S"), resourceName, pattern)
                local currentLog = LoadResourceFile(GetCurrentResourceName(), "backdoor_blocks.log") or ""
                SaveResourceFile(GetCurrentResourceName(), "backdoor_blocks.log", currentLog .. logEntry, -1)
            end
            
            return
        end
    end
    
    -- Check for known backdoor resources (exact match)
    if Config.BlacklistedResources then
        for _, blacklisted in ipairs(Config.BlacklistedResources) do
            if string.lower(resourceName) == string.lower(blacklisted) then
                StopResource(resourceName)
                print(string.format("^1[ANTI-BACKDOOR]^7 Stopped blacklisted resource: %s", resourceName))
                
                if Config.WebhookURL and Config.EnableWebhook then
                    TriggerEvent('anticheat:sendWebhook', {
                        title = "🔴 Blacklisted Resource Blocked",
                        description = string.format("**Resource:** %s\n**Action:** Stopped\n**Reason:** Resource is in blacklist", resourceName),
                        color = 16711680
                    })
                end
                
                if Config.LogBlockedResources then
                    local logEntry = string.format("[%s] BLACKLISTED: %s\n", os.date("%Y-%m-%d %H:%M:%S"), resourceName)
                    local currentLog = LoadResourceFile(GetCurrentResourceName(), "backdoor_blocks.log") or ""
                    SaveResourceFile(GetCurrentResourceName(), "backdoor_blocks.log", currentLog .. logEntry, -1)
                end
                
                return
            end
        end
    end
    
    -- Scan resource files for backdoor code
    if Config.ScanResourceFiles and Config.ShowBackdoorLocation then
        CreateThread(function()
            Wait(2000) -- Give resource time to start
            ScanResourceForBackdoors(resourceName)
        end)
    end
end)

-- Function to scan resource files for backdoor code patterns
function ScanResourceForBackdoors(resourceName)
    local resourcePath = GetResourcePath(resourceName)
    if not resourcePath then return end
    
    local suspiciousCodePatterns = {
        {pattern = "ExecuteCommand%s*%(", name = "ExecuteCommand injection"},
        {pattern = "TriggerServerEvent%s*%(%s*['\"]esx:give", name = "ESX money/item injection"},
        {pattern = "TriggerServerEvent%s*%(%s*['\"]qb%-.*:server:", name = "QBCore server event trigger"},
        {pattern = "mysql%.execute%s*%(%s*['\"]DROP", name = "SQL DROP command"},
        {pattern = "mysql%.execute%s*%(%s*['\"]DELETE%s+FROM", name = "SQL DELETE command"},
        {pattern = "SetEntityInvincible%s*%(%s*.*%s*,%s*true", name = "Godmode code"},
        {pattern = "SetPlayerInvincible%s*%(%s*.*%s*,%s*true", name = "Invincibility code"},
        {pattern = "GiveWeaponToPed%s*%(", name = "Weapon spawn code"},
        {pattern = "AddArmourToPed%s*%(%s*.*%s*,%s*999", name = "Abnormal armor code"},
        {pattern = "SetPedArmour%s*%(%s*.*%s*,%s*999", name = "Max armor exploit"},
        {pattern = "_G%[.*backdoor", name = "Global backdoor variable"},
        {pattern = "loadstring%s*%(", name = "Dynamic code execution"},
        {pattern = "load%s*%(%s*.*%s*%)%s*%(", name = "Code loader"},
    }
    
    local luaFiles = {
        "client.lua", "client/main.lua", "client/client.lua",
        "server.lua", "server/main.lua", "server/server.lua",
        "shared.lua", "config.lua"
    }
    
    local foundIssues = false
    
    for _, fileName in ipairs(luaFiles) do
        local fileContent = LoadResourceFile(resourceName, fileName)
        if fileContent then
            local lineNumber = 1
            for line in fileContent:gmatch("[^\r\n]+") do
                for _, check in ipairs(suspiciousCodePatterns) do
                    if string.match(line, check.pattern) then
                        foundIssues = true
                        print(string.format("^1[BACKDOOR FOUND]^7 Resource: ^3%s^7", resourceName))
                        print(string.format("  ^1File:^7 %s ^1Line:^7 %d", fileName, lineNumber))
                        print(string.format("  ^1Issue:^7 %s", check.name))
                        print(string.format("  ^1Code:^7 %s", line:match("^%s*(.-)%s*$")))
                        print("^3  Fix this line to remove the backdoor!^7")
                        print("")
                        
                        if Config.WebhookURL and Config.EnableWebhook then
                            TriggerEvent('anticheat:sendWebhook', {
                                title = "🔍 Backdoor Code Detected",
                                description = string.format(
                                    "**Resource:** %s\n**File:** %s\n**Line:** %d\n**Issue:** %s\n**Code:** ```lua\n%s\n```\n**Action:** Please review and fix this code",
                                    resourceName, fileName, lineNumber, check.name, line:match("^%s*(.-)%s*$")
                                ),
                                color = 16744192
                            })
                        end
                        
                        if Config.LogBlockedResources then
                            local logEntry = string.format(
                                "[%s] BACKDOOR CODE - Resource: %s, File: %s, Line: %d, Issue: %s\nCode: %s\n\n",
                                os.date("%Y-%m-%d %H:%M:%S"), resourceName, fileName, lineNumber, check.name, line
                            )
                            local currentLog = LoadResourceFile(GetCurrentResourceName(), "backdoor_blocks.log") or ""
                            SaveResourceFile(GetCurrentResourceName(), "backdoor_blocks.log", currentLog .. logEntry, -1)
                        end
                    end
                end
                lineNumber = lineNumber + 1
            end
        end
    end
    
    if foundIssues and Config.AutoStopSuspiciousResources then
        print(string.format("^1[ANTI-BACKDOOR]^7 Stopping resource '%s' due to backdoor code", resourceName))
        StopResource(resourceName)
    elseif foundIssues then
        print(string.format("^3[ANTI-BACKDOOR]^7 Resource '%s' has backdoor code - please fix the issues above!", resourceName))
    end
end

-- Monitor for unauthorized admin command execution
RegisterNetEvent('anticheat:checkAdminCommand')
AddEventHandler('anticheat:checkAdminCommand', function(command)
    local source = source
    local playerName = GetPlayerName(source)
    
    -- Check if player has admin permissions
    if not IsPlayerAceAllowed(source, Config.AdminAce) then
        suspiciousCommands[source] = (suspiciousCommands[source] or 0) + 1
        
        if suspiciousCommands[source] > 3 then
            TriggerEvent('anticheat:detection', source, "Backdoor Attempt", "BackdoorCommand", 
                string.format("Attempted admin command: %s (Attempts: %d)", command, suspiciousCommands[source]))
        end
        
        if Config.WebhookURL then
            TriggerEvent('anticheat:sendWebhook', {
                title = "⚠️ Unauthorized Admin Command",
                description = string.format("Player: **%s**\nCommand: **%s**\nAttempts: %d", 
                    playerName, command, suspiciousCommands[source]),
                color = 16744192
            })
        end
    end
end)

-- Protect critical server events from client triggers
for _, eventName in ipairs(protectedServerEvents) do
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function()
        local source = source
        local playerName = GetPlayerName(source)
        
        -- This should never be triggered from client
        detectedBackdoors[source] = (detectedBackdoors[source] or 0) + 1
        
        print(string.format("^1[ANTI-BACKDOOR]^7 %s attempted to trigger protected event: %s", playerName, eventName))
        
        if detectedBackdoors[source] >= 1 then
            TriggerEvent('anticheat:detection', source, "Backdoor Exploit", "ProtectedEvent", 
                string.format("Triggered protected event: %s", eventName))
        end
        
        if Config.WebhookURL then
            TriggerEvent('anticheat:sendWebhook', {
                title = "🔒 Protected Event Triggered",
                description = string.format("Player: **%s**\nEvent: **%s**\nBackdoor attempts: %d", 
                    playerName, eventName, detectedBackdoors[source]),
                color = 16711680
            })
        end
    end)
end

-- Scan all running resources for backdoor indicators
CreateThread(function()
    if not Config.EnableBackdoorCheck then return end
    
    Wait(10000) -- Wait for server to fully start
    
    local resources = {}
    local numResources = GetNumResources()
    
    for i = 0, numResources - 1 do
        local resourceName = GetResourceByFindIndex(i)
        if GetResourceState(resourceName) == 'started' then
            table.insert(resources, resourceName)
        end
    end
    
    print(string.format("^3[ANTI-BACKDOOR]^7 Scanning %d active resources for backdoors...", #resources))
    
    local suspiciousCount = 0
    local blockedCount = 0
    
    for _, resourceName in ipairs(resources) do
        local lowerName = string.lower(resourceName)
        
        -- Skip whitelisted resources
        local isWhitelisted = false
        if Config.WhitelistedResources then
            for _, whitelisted in ipairs(Config.WhitelistedResources) do
                if string.lower(resourceName) == string.lower(whitelisted) then
                    isWhitelisted = true
                    break
                end
            end
        end
        
        if not isWhitelisted then
            -- Check for backdoor patterns
            for _, pattern in ipairs(backdoorPatterns) do
                if string.match(lowerName, pattern) then
                    suspiciousCount = suspiciousCount + 1
                    print(string.format("^1[ANTI-BACKDOOR]^7 WARNING: Suspicious resource found: %s (Pattern: %s)", resourceName, pattern))
                    
                    if Config.AutoStopSuspiciousResources then
                        StopResource(resourceName)
                        blockedCount = blockedCount + 1
                        print(string.format("^1[ANTI-BACKDOOR]^7 Auto-stopped suspicious resource: %s", resourceName))
                    end
                    break
                end
            end
            
            -- Check blacklist
            if Config.BlacklistedResources then
                for _, blacklisted in ipairs(Config.BlacklistedResources) do
                    if string.lower(resourceName) == string.lower(blacklisted) then
                        suspiciousCount = suspiciousCount + 1
                        blockedCount = blockedCount + 1
                        print(string.format("^1[ANTI-BACKDOOR]^7 WARNING: Blacklisted resource found: %s", resourceName))
                        -- Auto-stop blacklisted resources
                        StopResource(resourceName)
                        print(string.format("^1[ANTI-BACKDOOR]^7 Stopped blacklisted resource: %s", resourceName))
                    end
                end
            end
        end
    end
    
    if suspiciousCount == 0 then
        print("^2[ANTI-BACKDOOR]^7 Resource scan complete - No suspicious resources detected!")
    else
        print(string.format("^1[ANTI-BACKDOOR]^7 Resource scan complete - Found %d suspicious resource(s), blocked %d", suspiciousCount, blockedCount))
        
        if Config.WebhookURL and Config.EnableWebhook then
            TriggerEvent('anticheat:sendWebhook', {
                title = "🔍 Resource Scan Complete",
                description = string.format("**Scanned:** %d resources\n**Suspicious:** %d\n**Blocked:** %d", #resources, suspiciousCount, blockedCount),
                color = suspiciousCount > 0 and 16744192 or 65280
            })
        end
    end
end)

-- Admin command to manually scan for backdoors
RegisterCommand('acscanbackdoor', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTI-BACKDOOR]", "You don't have permission to use this command"}
        })
        return
    end
    
    local resources = {}
    local numResources = GetNumResources()
    
    for i = 0, numResources - 1 do
        local resourceName = GetResourceByFindIndex(i)
        if GetResourceState(resourceName) == 'started' then
            table.insert(resources, resourceName)
        end
    end
    
    local message = string.format("^3[ANTI-BACKDOOR]^7 Scanning %d resources for backdoors...", #resources)
    if source == 0 then
        print(message)
    else
        TriggerClientEvent('chat:addMessage', source, {args = {message}})
    end
    
    local suspiciousCount = 0
    local suspiciousResources = {}
    
    for _, resourceName in ipairs(resources) do
        local lowerName = string.lower(resourceName)
        
        -- Skip whitelisted
        local isWhitelisted = false
        if Config.WhitelistedResources then
            for _, whitelisted in ipairs(Config.WhitelistedResources) do
                if string.lower(resourceName) == string.lower(whitelisted) then
                    isWhitelisted = true
                    break
                end
            end
        end
        
        if not isWhitelisted then
            for _, pattern in ipairs(backdoorPatterns) do
                if string.match(lowerName, pattern) then
                    suspiciousCount = suspiciousCount + 1
                    table.insert(suspiciousResources, resourceName)
                    break
                end
            end
            
            if Config.BlacklistedResources then
                for _, blacklisted in ipairs(Config.BlacklistedResources) do
                    if string.lower(resourceName) == string.lower(blacklisted) then
                        if not table.contains(suspiciousResources, resourceName) then
                            suspiciousCount = suspiciousCount + 1
                            table.insert(suspiciousResources, resourceName)
                        end
                    end
                end
            end
        end
    end
    
    if suspiciousCount == 0 then
        local msg = "^2[ANTI-BACKDOOR]^7 No suspicious resources found!"
        if source == 0 then
            print(msg)
        else
            TriggerClientEvent('chat:addMessage', source, {args = {msg}})
        end
    else
        local msg = string.format("^1[ANTI-BACKDOOR]^7 Found %d suspicious resource(s):", suspiciousCount)
        if source == 0 then
            print(msg)
            for _, res in ipairs(suspiciousResources) do
                print(string.format("  - %s", res))
            end
        else
            TriggerClientEvent('chat:addMessage', source, {args = {msg}})
            for _, res in ipairs(suspiciousResources) do
                TriggerClientEvent('chat:addMessage', source, {args = {"^1[ANTI-BACKDOOR]", string.format("- %s", res)}})
            end
        end
    end
end, false)

-- Helper function
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Monitor for SQL injection attempts via events
AddEventHandler('anticheat:checkSQLInjection', function(query)
    local source = source
    local playerName = GetPlayerName(source)
    
    local sqlPatterns = {
        "DROP%s+TABLE",
        "DELETE%s+FROM",
        "UPDATE%s+.*%s+SET",
        "INSERT%s+INTO",
        "UNION%s+SELECT",
        "'; ",
        "OR%s+1=1",
        "OR%s+'1'='1",
    }
    
    for _, pattern in ipairs(sqlPatterns) do
        if string.match(string.upper(query), pattern) then
            print(string.format("^1[ANTI-BACKDOOR]^7 SQL Injection attempt from: %s", playerName))
            
            TriggerEvent('anticheat:detection', source, "SQL Injection", "SQLInjection", 
                string.format("Query: %s", query:sub(1, 100)))
            
            if Config.WebhookURL then
                TriggerEvent('anticheat:sendWebhook', {
                    title = "💉 SQL Injection Attempt",
                    description = string.format("Player: **%s**\nQuery: ```%s```", 
                        playerName, query:sub(1, 200)),
                    color = 16711680
                })
            end
            return
        end
    end
end)

-- Check for file manipulation attempts
AddEventHandler('anticheat:checkFileAccess', function(filepath)
    local source = source
    local playerName = GetPlayerName(source)
    
    local dangerousPaths = {
        "server%.cfg",
        "server%.lua",
        "%.sql",
        "database",
        "admin",
        "config",
    }
    
    for _, pattern in ipairs(dangerousPaths) do
        if string.match(string.lower(filepath), pattern) then
            print(string.format("^1[ANTI-BACKDOOR]^7 Suspicious file access from: %s (File: %s)", playerName, filepath))
            
            TriggerEvent('anticheat:detection', source, "Unauthorized File Access", "FileAccess", 
                string.format("File: %s", filepath))
            return
        end
    end
end)

print("^2[Anti-Cheat]^7 Backdoor detection system loaded!")
