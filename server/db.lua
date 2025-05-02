SHOPS_SERVER = {}

lib.callback.register("mri_Qshops:server:insertShop", function(source, data)
    local source = source
    if not IsPlayerAceAllowed(source, "admin") then
        return TriggerClientEvent("ox_lib:notify", source, {
            type = "error",
            description = "Você não tem permissão para usar este comando."
        })
    end

    if data.label then
        local duplicate = MySQL.single.await("SELECT label FROM mri_qshops WHERE label = ?", {data.label})
        if duplicate then
            return
        end
    end

    local response = {
        type = "success",
        description = "Sucesso ao salvar!"

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
        response.reset = false
    end
    LoadShops(source, response)
    return true
end)

RegisterNetEvent("mri_Qshops:deleteShop", function(shoplabel)
    local source = source
    local sql = "DELETE FROM mri_qshops WHERE label = ?"
    local response = {
        type = "success",
        description = "Shop excluido!"

    }
    local result = MySQL.Sync.execute(sql, {shoplabel})

    if result <= 0 then
        response.type = "error"
        response.description = "Erro ao excluir."
        response.reset = false
    end
    LoadShops(source, response, true)
end)

lib.callback.register("mri_Qshops:server:updateShopLabel", function(source, Shop)
    local response = {
        type = "success",
        description = "Sucesso ao Update!"

    }
    local source = source
    if Shop.newLabel then
        local duplicate = MySQL.single.await("SELECT label FROM mri_qshops WHERE label = ?", {Shop.newLabel})
        if duplicate then
            return
        end

        local updated = MySQL.update.await("UPDATE mri_qshops SET label = ? WHERE label = ?", {Shop.newLabel, Shop.label})
        if updated <= 0 then
            return
        end
    end
    LoadShops(source, response)
    return true
end)

lib.callback.register("mri_Qshops:server:updateShopJob", function(source, Shop)
    local source = source

    local existingJob = MySQL.scalar.await("SELECT jobname FROM mri_qshops WHERE label = ?", {Shop.label})

    if existingJob == Shop.newJob then
        return
    end

    local updated = MySQL.update.await("UPDATE mri_qshops SET jobname = ? WHERE label = ?", {Shop.newJob, Shop.label})
    if updated <= 0 then
        return
    end

    return true
end)

RegisterNetEvent("mri_Qshops:UpdateShop", function(Shop)
    local response = {
        type = "success",
        description = "Sucesso ao Update!"

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
        updateShopField("UPDATE mri_qshops SET shopcoords = ? WHERE label = ?",
            {json.encode(Shop.shopcoords), Shop.label})
    end

    if Shop.storagecoords then
        updateShopField("UPDATE mri_qshops SET storagecoords = ? WHERE label = ?",
            {json.encode(Shop.storagecoords), Shop.label})
    end

    if Shop.menucoords then
        updateShopField("UPDATE mri_qshops SET menucoords = ? WHERE label = ?",
            {json.encode(Shop.menucoords), Shop.label})
    end

    if Shop.blipenabled then
        updateShopField("UPDATE mri_qshops SET blipdata = ? WHERE label = ?", {json.encode({
            blipname = Shop.blipname,
            blipcolor = Shop.blipcolor,
            blipenabled = Shop.blipenabled,
            blipsprite = Shop.blipsprite,
            blipscale = Shop.blipscale,
            blipcoords = Shop.blipcoords
        }), Shop.label})
    end
    LoadShops(source, response)
end)

RegisterNetEvent("mri_Qshops:Saveshop", function(source)
    local response = {
        type = "success",
        description = "Sucesso ao Salvar!"
    }
    TriggerEvent("mri_Qshops:server:createHooks")
    LoadShops(source, response, true)
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
				interaction = v.interaction,
				blipdata = json.decode(v.blipdata),
				menucoords = json.decode(v.menucoords),
				storagecoords = json.decode(v.storagecoords),
				shopcoords = json.decode(v.shopcoords),
			}
			shops[k] = sho
		end
	end
	SHOPS_SERVER = shops
	return SHOPS_SERVER
end
exports("GetShops", GetShops)

function LoadShops(source, response, up)
    local shops = GetShops()
    if up then
        TriggerClientEvent("mri_Qshops:updatesDBshop", -1, shops)
    end
    if response then
        TriggerClientEvent("ox_lib:notify", source, response)
    end
end

lib.callback.register("mri_Qshops:server:LoadShops", function(source)
    local response = {}
    return LoadShops(source, response, true)
end)

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

function GetMaxShopId()
    local sql = "SELECT MAX(id) as maxId FROM mri_qshops"
    local result = MySQL.Sync.fetchAll(sql, {})
    return result[1] and result[1].maxId or 0
end

lib.callback.register("mri_Qshops:server:GetMaxShopId", function(source)
    return GetMaxShopId()
end)

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
        TriggerEvent("mri_Qshops:server:createHooks")
    end)
end

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("Recurso " .. resourceName .. " iniciado. Verificando/criando tabelas...")
        createTables()
    end
end)
