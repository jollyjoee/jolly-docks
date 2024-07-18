-- QBCore Exports / Variables --
local QBCore = exports['qb-core']:GetCoreObject()
local active = true

CreateThread(function()
    local seconds = math.floor(Config.Timeout * 60000)
    while true do
        Wait(1000)
        if active then
            Wait((Config.Cooldown * 60000))
            TriggerEvent('jolly-docks:server:start')
            active = false
            timeout = true
        end
        if timeout then
            if seconds > 0 then
                seconds = seconds - 1000
            elseif seconds <= 0 then
                seconds = Config.Timeout * 60000
                TriggerClientEvent('jolly-docks:client:timeout', -1)
                TriggerEvent('jolly-docks:server:end')
                TriggerEvent('docks:notifycancelled')
                active = true
                timeout = false
            end
        end
    end
end)

RegisterNetEvent('jolly-docks:server:start', function()
    TriggerEvent('docks:notify')
    local coord = random_elem(Config.Locations)
    TriggerClientEvent('jolly-docks:client:set', -1, coord)
end)

function random_elem(tb)
    local keys = {}
    for k in pairs(tb) do table.insert(keys, k) end
    return tb[keys[math.random(#keys)]]
end

RegisterNetEvent('jolly-docks:server:AddRemoveItem', function(item, count, type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    if type == 'add' then
        if item == 'money' then
            Player.Functions.AddMoney('cash', count)
        else
            Player.Functions.AddItem(item, count)
            TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', count)
        end
    elseif type == 'remove' then
        if item == 'money' then
            Player.Functions.RemoveMoney('cash', count)
        else
            Player.Functions.RemoveItem(item, count)
            TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', count)
        end
    end
end)

RegisterNetEvent('jolly-docks:server:end', function(id)
    active = true
    timeout = false
    TriggerClientEvent('jolly-docks:client:removeinteraction', -1, id)
end)

QBCore.Functions.CreateCallback('jolly-docks:server:itemcallback', function(source, cb, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasItem = Player.Functions.GetItemByName(item)
    if hasItem then
        cb(true)
    else
        cb(false)
    end
end)