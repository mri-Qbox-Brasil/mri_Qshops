if not IsQBCore() then
	return
end

local QBCore = exports["qb-core"]:GetCoreObject()

AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
	PlayerData = QBCore.Functions.GetPlayerData()
	local shops = lib.callback.await("mri_Qshops:server:GetShops")
	exports.mri_Qshops:mriMenuShops(shops)
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
	PlayerData = {}
end)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(val)
	local invokingResource = GetInvokingResource()
	if invokingResource and invokingResource ~= "qb-core" and invokingResource ~= "qbx-core" then
		return
	end -- Not sure if this accounts for the provide setter
	PlayerData = val
end)

function IsBoss()
	return PlayerData.job.isboss
end

function OpenBossMenu()
    exports.qbx_management:OpenBossMenu("job")
end

function Jobname()
	return PlayerData.job.name
end
AddEventHandler("onResourceStart", function(resource)
	if cache.resource == resource then
		Wait(5000)
		PlayerData = QBCore.Functions.GetPlayerData()
		local shops = lib.callback.await("mri_Qshops:server:GetShops")
		exports.mri_Qshops:mriMenuShops(shops)
	end
end)

QB = {
	TriggerCallback = function(name, cb, ...)
		if QBCore ~= nil then
			QBCore.Functions.TriggerCallback(name, cb, ...)
		end
	end,

	RegisterCallback = function(name, cb)
		if QBCore ~= nil then
			QBCore.Functions.CreateCallback(name, cb)
		end
	end,
}
