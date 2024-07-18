-- QBCore Exports / Variables --
local QBCore = exports['qb-core']:GetCoreObject()
if Config.Debug then
    dist = 2000.0
else
    dist = 6.0
end
RegisterNetEvent('jolly-docks:client:set', function(coord)
    local id = 'test'
    exports.interact:AddInteraction({coords = coord, distance = dist, interactDst = 3.0, id = id,
        options = {
            {
                label = 'Open Container',
                action = function()
                    Startdocks(id)
                end,
            },
        }
    })    
end)

RegisterNetEvent('jolly-docks:client:removeinteraction', function(id)
    exports.interact:RemoveInteraction(id)
end)

function Startdocks(id)
    QBCore.Functions.TriggerCallback('jolly-docks:server:itemcallback', function(hasItem)
        if hasItem then
            local playerPed = PlayerPedId()
            while not HasAnimDictLoaded(Config.Animdict) do RequestAnimDict(Config.Animdict) Wait(100) end
            TaskPlayAnim(playerPed, Config.Animdict, Config.Anim, 8.0, 8.0, -1, 1, 1, false, false, false)
            TriggerServerEvent('jolly-docks:server:AddRemoveItem', Config.RequiredItem, 1, 'remove')
            exports['skillchecks']:startLockpickingGame(30000, 7, 5, function(success)
                if success then
                    ClearPedTasks(playerPed)
                    GiveRewards()              
                    TriggerServerEvent('docks:notifytaken')
                    TriggerServerEvent('jolly-docks:server:end', id)
                else
                    if Config.Debug then
                        ClearPedTasks(playerPed)
                        GiveRewards()              
                        TriggerServerEvent('docks:notifytaken')
                        TriggerServerEvent('jolly-docks:server:end', id)
                    else
                        ClearPedTasks(playerPed)
                        TriggerServerEvent('hud:server:GainStress', math.random(10, 30))
                    end
 
                end
            end)
        else
            QBCore.Functions.Notify('You need an Advanced Lockpick for this!', 'error', 5000)
        end
    end, Config.RequiredItem)
end

function GiveRewards()
    for k, v in pairs(Config.Loottable) do
        local chance = math.random(0, 100)
        if chance <= v.chance then
            if v.type == 'cash' then
                TriggerServerEvent('jolly-docks:server:AddRemoveItem', 'money', v.amount, 'add')
            else
                TriggerServerEvent('jolly-docks:server:AddRemoveItem', v.name, v.amount, 'add')
            end
        end
    end
end