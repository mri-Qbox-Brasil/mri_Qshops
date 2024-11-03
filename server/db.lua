Shops = {}
function CreateTable()
    MySQL.Sync.execute([[
            CREATE TABLE IF NOT EXISTS `mri_Qshops` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
                `label` text DEFAULT  NULL,
                `jobname` text DEFAULT  NULL,
                `target` text DEFAULT  NULL,
                `drawmaker` text DEFAULT  NULL,
                `blipcoords` longtext DEFAULT NULL,
                `blipName` text DEFAULT  NULL,
                `blipSprite` longtext DEFAULT NULL,
                `blipCor` longtext DEFAULT NULL,
                `blipscale` longtext DEFAULT NULL,
                `blipEnabled` varchar(255) DEFAULT NULL,
                `MenuCoords` longtext DEFAULT NULL,
                `Menusprite` longtext DEFAULT NULL,
                `MenuEnabled` varchar(255) DEFAULT NULL,
                `armazemCoords` longtext DEFAULT NULL,
                `armazemsprite` longtext DEFAULT NULL,
                `shopCoords` longtext DEFAULT NULL,
                `shopsprite` longtext DEFAULT NULL,
                PRIMARY KEY (`id`) USING BTREE,
               UNIQUE KEY `id` (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
   ]])
end

CreateTable()

local function dispatchEvents(source, response)
    TriggerClientEvent('mri_Qshops:updateshop', -1, Shops)
    if response then
        TriggerClientEvent('ox_lib:notify', source, response)
    end
end

RegisterNetEvent('mri-qshops:insertShop', function(data)
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao salvar!'
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
        params["@" .. k] = v -- Associa a chave ao valor correspondente
    end

    local result = MySQL.Sync.execute(string.format(sql, columns, placeholders), params)
    print(string.format(sql, columns, placeholders), params, 'insertshop')
    if result <= 0 then
        response.type = 'error'
        response.description = 'Erro ao enviar dados.'
    end
    getShops(source, response)
end)

RegisterNetEvent('mri_Qshops:deleteShop', function(shoplabel)
    local source = source
    local sql = "DELETE FROM mri_Qshops WHERE label = ?"
    local response = {
        type = 'success',
        description = 'Shop excluido!'
    }
    local result = MySQL.Sync.execute(sql, { shoplabel })

    if result <= 0 then
        response.type = 'error'
        response.description = 'Erro ao excluir.'
    end
    getShops(source, response)
end)

RegisterNetEvent('mri-Qshops:BossmenuUpdateShop', function(Shop)
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao Update!'
    }
    local sql = "UPDATE mri_Qshops SET MenuCoords = ?, MenuEnabled = ?, Menusprite = ? WHERE label = ?"
    -- print(name)
    MySQL.update.await(sql, { json.encode(Shop.MenuCoords), Shop.MenuEnabled, Shop.Menusprite, Shop.label  })
    getShops(source, response)
end)

RegisterNetEvent('mri_Qshops:ArmazemUpdateShop', function(shop)
    print(json.encode(shop),'armazem')
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao Update!'
    }
    local sql = "UPDATE mri_Qshops SET armazemCoords = ?, armazemsprite = ? , MenuEnabled = ? WHERE label = ?"
    -- print(name)
    MySQL.update.await(sql, { json.encode(shop.armazemCoords), shop.armazemsprite, shop.MenuEnabled ,shop.label })
    getShops(source, response)
end)

RegisterNetEvent('mri_Qshops:BlipUpdateShop', function(blipshop)
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao Update!'
    }
    local sql =
    "UPDATE mri_Qshops SET blipName = ?,blipCor = ? ,blipEnabled = ?,blipSprite = ?,blipscale = ?, blipcoords = ? WHERE label = ?"

    MySQL.update.await(sql,{ blipshop.blipName, blipshop.blipCor, blipshop.blipEnabled, blipshop.blipSprite,blipshop.blipscale, json.encode(blipshop.blipcoords), blipshop.label})

    getShops(source, response)
end)

RegisterNetEvent('mri_Qshops:BancadashopUpdateShop', function(Shop, name)
    local source = source
    local response = {
        type = 'success',
        description = 'Sucesso ao Update!'
    }
    local sql = "UPDATE mri_Qshops SET shopCoords = ? , shopsprite = ? WHERE label = ?"

    MySQL.update.await(sql, { json.encode(Shop.shopCoords), json.encode(Shop.shopsprite), name })
    getShops(source, response)
end)

function getShops(source, response)
    local sql = 'SELECT * FROM mri_Qshops'
    local result = MySQL.Sync.fetchAll(sql, {})
    local shops = {}
    if result and #result > 0 then
        for k, v in ipairs(result) do
            print(json.encode(k))
            local sho = {
                id = v.id,
                label = v.label,
                jobname = v.jobname,
                target = v.target,
                drawmaker = v.drawmaker,
                blipName = v.blipName,
                blipcoords = json.decode(v.blipcoords),
                blipSprite = tonumber(v.blipSprite),
                blipCor = tonumber(v.blipCor),
                blipEnabled = v.blipEnabled,
                blipscale = tonumber(v.blipscale),
                MenuCoords = json.decode(v.MenuCoords),
                Menusprite = tonumber(v.Menusprite),
                MenuEnabled = v.MenuEnabled,
                armazemCoords = json.decode(v.armazemCoords),
                armazemsprite = tonumber(v.armazemsprite),
                shopCoords = json.decode(v.shopCoords),
                shopsprite = tonumber(v.shopsprite)
            }
            shops[k] = sho
        end
    end
    Shops = shops
    print(json.encode(Shops),'select')
    dispatchEvents(source, response)
end

AddEventHandler('onResourceStart', function(resourceName)
    Wait(400)
    if GetCurrentResourceName() == resourceName then
        getShops()
    end
end)
