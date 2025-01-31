if not IsESX() then return end

local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    lib.callback.await("mri_Qshops:server:LoadShops", false)
    TriggerServerEvent("mri_Qshops:server:createHooks")
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    table.wipe(PlayerData)
end)

RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

function IsBoss()
    return PlayerData.job.grade_name == 'boss'
end

function OpenBossMenu(job)
    TriggerEvent('esx_society:openBossMenu', job, function(_, menu)
        menu.close()
    end, {wash = false})
end

AddEventHandler('onResourceStart', function(resource)
    if cache.resource == resource then
        Wait(500)
        PlayerData = ESX.GetPlayerData()
        lib.callback.await("mri_Qshops:server:LoadShops", false)
        TriggerServerEvent("mri_Qshops:server:createHooks")
    end
end)