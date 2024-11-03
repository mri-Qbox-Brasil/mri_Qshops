SHOPS_SERVER = {}

RegisterNetEvent("mri-qshops:insertShop", function(data)
	local source = source

	if not IsPlayerAceAllowed(source, "admin") then 
		return TriggerClientEvent("ox_lib:notify", source, {
			type = "error",
			description = "Você não tem permissão para usar este comando.",
		})
	end
	local response = {
		type = "success",
		description = "Sucesso ao salvar!",
	}
	local sql = "INSERT INTO `mri_Qshops` (%s) VALUES (%s)"
	local columns = ""
	local placeholders = ""
	local params = {}

	for k, v in pairs(data) do
		if columns == "" then
			columns = k
			placeholders = "@" .. k
		else
			columns = columns .. ", " .. k
			placeholders = placeholders .. ", @" .. k
		end
		params["@" .. k] = v
	end

	local result = MySQL.Sync.execute(string.format(sql, columns, placeholders), params)
	print(string.format(sql, columns, placeholders), params, "insertshop")
	if result <= 0 then
		response.type = "error"
		response.description = "Erro ao enviar dados."
	end
	GetShops(source, response)
end)

RegisterNetEvent("mri_Qshops:deleteShop", function(shoplabel)
	local source = source
	local sql = "DELETE FROM mri_Qshops WHERE label = ?"
	local response = {
		type = "success",
		description = "Shop excluido!",
	}
	local result = MySQL.Sync.execute(sql, { shoplabel })

	if result <= 0 then
		response.type = "error"
		response.description = "Erro ao excluir."
	end
	GetShops(source, response)
end)

RegisterNetEvent("mri-Qshops:UpdateShop", function(Shop)
	local response = {
		type = "success",
		description = "Sucesso ao Update!",
	}
	local source = source

	local function updateShopField(sql, params)
		local result = MySQL.update.await(sql, params)
		if result <= 0 then
			response.type = "error"
			response.description = "Erro ao excluir."
		end
	end

	if Shop.shopCoords then
		updateShopField(
			"UPDATE mri_Qshops SET shopCoords = ? WHERE label = ?",
			{ json.encode(Shop.shopCoords), Shop.label }
		)
	end

	if Shop.armazemCoords then
		updateShopField(
			"UPDATE mri_Qshops SET armazemCoords = ? WHERE label = ?",
			{ json.encode(Shop.armazemCoords), Shop.label }
		)
	end

	if Shop.MenuCoords then
		updateShopField(
			"UPDATE mri_Qshops SET MenuCoords = ?, MenuBossEnabled = ? WHERE label = ?",
			{ json.encode(Shop.MenuCoords), Shop.MenuBossEnabled, Shop.label }
		)
	end

	if Shop.blipEnabled then
		updateShopField(
			"UPDATE mri_Qshops SET blipName = ?, blipCor = ?, blipEnabled = ?, blipSprite = ?, blipscale = ?, blipcoords = ? WHERE label = ?",
			{
				Shop.blipName,
				Shop.blipCor,
				Shop.blipEnabled,
				Shop.blipSprite,
				Shop.blipscale,
				json.encode(Shop.blipcoords),
				Shop.label,
			}
		)
	end

	GetShops(source, response)
end)

function GetShops(source, response)
	local sql = "SELECT * FROM mri_Qshops"
	local result = MySQL.Sync.fetchAll(sql, {})
	local shops = {}
	if result and #result > 0 then
		for k, v in ipairs(result) do
			print(json.encode(k), "teste")
			local sho = {
				id = v.id,
				label = v.label,
				jobname = v.jobname,
				target = v.target,
				drawmaker = v.drawmaker,
				blipName = v.blipName,
				MenuBossEnabled = v.MenuBossEnabled,
				blipcoords = json.decode(v.blipcoords),
				blipSprite = tonumber(v.blipSprite),
				blipCor = tonumber(v.blipCor),
				blipEnabled = v.blipEnabled,
				blipscale = tonumber(v.blipscale),
				MenuCoords = json.decode(v.MenuCoords),
				MenuEnabled = v.MenuEnabled,
				armazemCoords = json.decode(v.armazemCoords),
				shopCoords = json.decode(v.shopCoords),
			}
			shops[k] = sho
		end
	end
	SHOPS_SERVER = shops
	TriggerClientEvent("mri_Qshops:updatesDBshop", -1, SHOPS_SERVER)
	if response then
		TriggerClientEvent("ox_lib:notify", source, response)
	end
	return SHOPS_SERVER
end
exports("GetShops", GetShops)

local function splitStr(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		str = string.gsub(str, "^%s*(.-)%s*$", "%1")
		if not (str == nil or str == "") then
			table.insert(t, str)
		end
	end
	return t
end

local function executeQueries(queries, callback)
	local index = 1
	local function executeNextQuery()
		if index > #queries then
			if callback then
				callback()
			end
			return
		end
		MySQL.Async.execute(queries[index], {}, function()
			print("Tabela verificada/criada: " .. index)
			index = index + 1
			executeNextQuery()
		end)
	end
	executeNextQuery()
end

local function createTables()
	local filePath = "database.sql"
	local queries = splitStr(LoadResourceFile(GetCurrentResourceName(), filePath), ";")

	executeQueries(queries, function()
		print("Todas as tabelas foram verificadas/criadas.")
		GetShops()
		TriggerEvent("mri_Qshops:server:createHooks")
	end)
end

AddEventHandler("onResourceStart", function(resourceName)
	if GetCurrentResourceName() == resourceName then
		print("Recurso " .. resourceName .. " iniciado. Verificando/criando tabelas...")
		createTables()
	end
end)
