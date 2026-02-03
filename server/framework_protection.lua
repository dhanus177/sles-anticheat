-- ESX/QBCore Framework Integration
-- Protects money, items, and job systems

local ESX = nil
local QBCore = nil

-- Detect framework
CreateThread(function()
    -- Try ESX
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        print("^2[ANTI-CHEAT]^7 ESX Framework detected")
    end
    
    -- Try QBCore
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        print("^2[ANTI-CHEAT]^7 QBCore Framework detected")
    end
    
    if not ESX and not QBCore then
        print("^3[ANTI-CHEAT]^7 No framework detected - some features disabled")
    end
end)

-- Monitor money changes (ESX)
if ESX then
    -- Hook into money add/remove events
    RegisterServerEvent('esx:giveInventoryItem')
    AddEventHandler('esx:giveInventoryItem', function(target, type, item, count)
        local source = source
        
        -- Block if not admin
        if not IsPlayerAceAllowed(source, Config.AdminAce) then
            CancelEvent()
            DetectionHandler(source, "Unauthorized Inventory Modification", "Exploit", 
                string.format("Attempted to give %s x%d to player %d", item, count, target))
        end
    end)
    
    -- Monitor money additions
    AddEventHandler('esx:addMoney', function(source, account, amount)
        if amount > 50000 and not IsPlayerAceAllowed(source, Config.AdminAce) then
            -- Large money addition - suspicious
            DetectionHandler(source, "Suspicious Money Add", "Exploit",
                string.format("Added $%d to %s account", amount, account))
        end
    end)
end

-- Monitor money changes (QBCore)
if QBCore then
    -- Hook into money events
    RegisterServerEvent('QBCore:Server:OnMoneyChange')
    AddEventHandler('QBCore:Server:OnMoneyChange', function(source, moneyType, amount, reason)
        if amount > 50000 and not IsPlayerAceAllowed(source, Config.AdminAce) then
            DetectionHandler(source, "Suspicious Money Change", "Exploit",
                string.format("Changed %s by $%d (Reason: %s)", moneyType, amount, reason))
        end
    end)
end

-- Block common exploit events
local ProtectedESXEvents = {
    'esx:giveInventoryItem',
    'esx:giveMoney', 
    'esx_dmvschool:pay',
    'esx_drugs:startHarvestWeed',
    'esx_drugs:startTransformWeed',
    'esx_drugs:startSellWeed',
    'esx_policejob:handcuff',
    'esx_ambulancejob:revive',
    'esx_society:withdrawMoney',
    'esx_society:depositMoney',
    'esx_vehicleshop:setVehicleOwned'
}

local ProtectedQBEvents = {
    'QBCore:Server:SetMetaData',
    'QBCore:Server:AddMoney',
    'QBCore:Server:SetMetaData',
    'QBCore:Server:AddMoney',
    'QBCore:Server:RemoveMoney',
    'qb-banking:server:DepositMoney',
    'qb-banking:server:WithdrawMoney',
    'qb-vehicleshop:server:buyVehicle'
}

-- Register protected event handlers
for _, eventName in ipairs(ProtectedESXEvents) do
    RegisterServerEvent(eventName)
    AddEventHandler(eventName, function()
        local source = source
        if not IsPlayerAceAllowed(source, Config.AdminAce) then
            CancelEvent()
            DetectionHandler(source, "Protected Event Triggered", "Exploit",
                "Event: " .. eventName)
        end
    end)
end

for _, eventName in ipairs(ProtectedQBEvents) do
    RegisterServerEvent(eventName)
    AddEventHandler(eventName, function()
        local source = source
        if not IsPlayerAceAllowed(source, Config.AdminAce) then
            CancelEvent()
            DetectionHandler(source, "Protected Event Triggered", "Exploit",
                "Event: " .. eventName)
        end
    end)
end

-- Monitor item additions
RegisterNetEvent('anticheat:itemAdded')
AddEventHandler('anticheat:itemAdded', function(item, count)
    local source = source
    
    -- Skip detection for whitelisted items
    if WhitelistedItems[item] then
        return
    end
    
    -- Large item counts = duplication
    if count > 100 then
        DetectionHandler(source, "Item Duplication", "Exploit",
            string.format("Added %s x%d", item, count))
    end
end)

-- Job change protection
if ESX then
    RegisterServerEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(source, job, grade)
        if not IsPlayerAceAllowed(source, Config.AdminAce) then
            CancelEvent()
            DetectionHandler(source, "Unauthorized Job Change", "Exploit",
                string.format("Attempted to set job to %s (grade %d)", job, grade))
        end
    end)
end

print("^2[ANTI-CHEAT]^7 Framework protection loaded")
