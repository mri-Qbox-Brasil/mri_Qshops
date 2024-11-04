SHOPS_SERVER = {}

RegisterNetEvent("mri_Qshops:insertShop", function(data)
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
	local sql = "INSERT INTO `mri_qshops` (%s) VALUES (%s)"
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
	if result <= 0 then
		response.type = "error"
		response.description = "Erro ao enviar dados."
	end
	GetShops(source, response)
end)

RegisterNetEvent("mri_Qshops:deleteShop", function(shoplabel)
	local source = source
	local sql = "DELETE FROM mri_qshops WHERE label = ?"
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

RegisterNetEvent("mri_Qshops:UpdateShop", function(Shop)
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

	if Shop.shopcoords then
		updateShopField(
			"UPDATE mri_qshops SET shopcoords = ? WHERE label = ?",
			{ json.encode(Shop.shopcoords), Shop.label }
		)
	end

	if Shop.storagecoords then
		updateShopField(
			"UPDATE mri_qshops SET storagecoords = ? WHERE label = ?",
			{ json.encode(Shop.storagecoords), Shop.label }
		)
	end

	if Shop.menucoords then
		updateShopField(
			"UPDATE mri_qshops SET menucoords = ?, menuenabled = ? WHERE label = ?",
			{ json.encode(Shop.menucoords), Shop.menuenabled, Shop.label }
		)
	end

	if Shop.blipenabled then
		updateShopField(
			"UPDATE mri_qshops SET blipname = ?, blipcolor = ?, blipenabled = ?, blipsprite = ?, blipscale = ?, blipcoords = ? WHERE label = ?",
			{
				Shop.blipname,
				Shop.blipcolor,
				Shop.blipenabled,
				Shop.blipsprite,
				Shop.blipscale,
				json.encode(Shop.blipcoords),
				Shop.label,
			}
		)
	end

	GetShops(source, response)
end)

function GetShops(source, response)
	local sql = "SELECT * FROM mri_qshops"
	local result = MySQL.Sync.fetchAll(sql, {})
	local shops = {}
	if result and #result > 0 then
		for k, v in ipairs(result) do
			local sho = {
				id = v.id,
				label = v.label,
				jobname = v.jobname,
				target = v.target,
				drawmaker = v.drawmaker,
				blipname = v.blipname,
				blipcoords = json.decode(v.blipcoords),
				blipsprite = tonumber(v.blipsprite),
				blipcolor = tonumber(v.blipcolor),
				blipenabled = v.blipenabled,
				blipscale = tonumber(v.blipscale),
				menucoords = json.decode(v.menucoords),
				menuenabled = v.menuenabled,
				storagecoords = json.decode(v.storagecoords),
				shopcoords = json.decode(v.shopcoords),
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
