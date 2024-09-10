Shops = GlobalState.Shops or {}

function CreateTable()
    MySQL.Sync.execute([[
            CREATE TABLE IF NOT EXISTS `mri_Qshops` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
                `label` text DEFAULT  NULL,
                `jobname` text DEFAULT  NULL,
                `blipCoords` longtext DEFAULT NULL,
                `blipName` text DEFAULT  NULL,
                `blipDistancia` longtext DEFAULT NULL,
                `blipCor` longtext DEFAULT NULL,
                `blipEscala` longtext DEFAULT NULL,
                `blipEnabled` varchar(255) DEFAULT NULL,
                `MenuCoords` longtext DEFAULT NULL,
                `MenuDistancia` longtext DEFAULT NULL,
                `MenuEnabled` varchar(255) DEFAULT NULL,
                `armazemCoords` longtext DEFAULT NULL,
                `armazemDistancia` longtext DEFAULT NULL,
                `shopCoords` longtext DEFAULT NULL,
                `shopDistancia` longtext DEFAULT NULL,
                PRIMARY KEY (`id`) USING BTREE,
               UNIQUE KEY `id` (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
   ]])
end

local function dispatchEvents(source, response)
    GlobalState:set('Shops', Shops, true)
    TriggerClientEvent("mri-Qshops:carregarshop", -1)
    TriggerClientEvent("mri-Qshops:dispatchEvents", -1)
    -- Wait(2000)
    if response then
        print('pasei por aqui')
        TriggerClientEvent('ox_lib:notify', source, response)
    end
end

RegisterNetEvent('mri-qshops:InserirShop', function(data)
    print(json.encode(data))
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao salvar!'
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
        params["@" .. k] = v -- Associa a chave ao valor correspondente
    end

    MySQL.Async.execute(string.format(sql, columns, placeholders), params)
    print(string.format(sql, columns, placeholders))
    dispatchEvents(source, response)
end)

RegisterNetEvent('mri-Qshops:SelectStartShop', function(resource)
    local sql = 'SELECT * FROM mri_Qshops'
    local result = MySQL.Sync.fetchAll(sql, {})
    local shops = {}
    if result and #result > 0 then
        for k, row in ipairs(result) do
            local sho = {
                id = row.id,
                label = row.label,
                jobname = json.decode(row.jobname),
                blipName = row.blipName,
                blipCoords = json.decode(row.blipCoords),
                blipDistancia = row.blipDistancia,
                blipCor = row.blipCor,
                blipEnabled = row.blipEnabled,
                blipEscala = row.blipEscala,
                MenuCoords = json.decode(row.MenuCoords),
                MenuDistancia = row.MenuDistancia,
                MenuEnabled = row.MenuEnabled,
                armazemCoords = json.decode(row.armazemCoords),
                armazemDistancia = row.armazemDistancia,
                shopCoords = json.decode(row.shopCoords),
                shopDistancia = row.shopDistancia
            }
            shops[k] = sho
            print(json.encode(sho))
        end
    end
    Shops = shops
    dispatchEvents(source)
end)

RegisterNetEvent('mri-qshops:DeletarShop', function(shoplabel)
    local source = source
    local sql = "DELETE FROM mri_qshops WHERE label = ?"
    local response = {
        type = 'success',
        description = 'Shop excluido!'
    }
    local result = MySQL.Sync.execute(sql, {shoplabel})

    if result <= 0 then
        response.type = 'error'
        response.description = 'Erro ao excluir.'
    end
    dispatchEvents(source, response)
end)

RegisterNetEvent('mri-qshops:BossmenuAtualizacaoShop', function(Shop, name)
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao Update!'
    }
    local sql = "UPDATE mri_qshops SET MenuCoords = ?, MenuEnabled = ?, MenuDistancia = ? WHERE label = ?"
    -- print(name)
    MySQL.update.await(sql, {json.encode(Shop.MenuCoords), Shop.bossMenu_enabled, Shop.MenuDistancia, name})
    dispatchEvents(source, response)
end)

RegisterNetEvent('mri-qshops:ArmazemAtualizacaoShop', function(Shop, name)
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao Update!'
    }
    local sql = "UPDATE mri_qshops SET armazemCoords = ?, armazemDistancia = ? WHERE label = ?"
    -- print(name)
    MySQL.update.await(sql, {json.encode(Shop.armazemCoords), Shop.armazemDistancia, name})
    dispatchEvents(source, response)
end)

RegisterNetEvent('mri-qshops:BlipAtualizacaoShop', function(blipshop, name)
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao Update!'
    }
    local sql =
        "UPDATE mri_qshops SET blipName = ?,blipCor = ? ,blipEnabled = ?,blipDistancia = ?,blipEscala = ?, blipCoords = ? WHERE label = ?"
    print(name)

    MySQL.update.await(sql,
        {blipshop.blipName, json.encode(blipshop.blipCor), blipshop.blipEnabled, blipshop.blipDistancia,
         blipshop.blipEscala, json.encode(blipshop.blipCoords), name})

    dispatchEvents(source, response)
end)
RegisterNetEvent('mri-qshops:BancadashopAtualizacaoShop', function(Shop, name)
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao Update!'
    }
    local sql = "UPDATE mri_qshops SET shopCoords = ? , shopDistancia = ? WHERE label = ?"

    MySQL.update.await(sql, {json.encode(Shop.shopCoords), json.encode(Shop.shopDistancia), name})
    dispatchEvents(source, response)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        local sql = 'SELECT * FROM mri_Qshops'
        local result = MySQL.Sync.fetchAll(sql, {})
        local shops = {}
        if result and #result > 0 then
            for k, row in ipairs(result) do
                local sho = {
                    id = row.id,
                    label = row.label,
                    jobname = json.decode(row.jobname),
                    blipName = row.blipName,
                    blipCoords = json.decode(row.blipCoords),
                    blipDistancia = row.blipDistancia,
                    blipCor = row.blipCor,
                    blipEnabled = row.blipEnabled,
                    blipEscala = row.blipEscala,
                    MenuCoords = json.decode(row.MenuCoords),
                    MenuDistancia = row.MenuDistancia,
                    MenuEnabled = row.MenuEnabled,
                    armazemCoords = json.decode(row.armazemCoords),
                    armazemDistancia = row.armazemDistancia,
                    shopCoords = json.decode(row.shopCoords),
                    shopDistancia = row.shopDistancia
                }
                shops[k] = sho
                print(json.encode(sho))
            end
        end
        Shops = shops
        dispatchEvents(source)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("Recurso " .. resourceName .. " iniciado. Verificando/criando tabelas...")
        CreateTable()
    end
end)
