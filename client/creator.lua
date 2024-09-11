function ShopsDataBase()
    Shops = GlobalState.Shops or {}
    shop = {}
    for k, v in pairs(Shops) do
        shop[#shop + 1] = {
            id = v.id,
            label = v.id,
            jobname = v.jobname,
            blipName = v.blipName,
            blipCoords = v.blipCoords,
            blipDistancia = v.blipDistancia,
            blipCor = v.blipCor,
            blipEnabled = v.blipEnabled,
            blipEscala = v.blipEscala,
            MenuCoords = v.MenuCoords,
            MenuDistancia = v.MenuDistancia,
            MenuEnabled = v.MenuEnabled,
            armazemCoords = v.armazemCoords,
            armazemDistancia = v.armazemDistancia,
            shopCoords = v.shopCoords,
            shopDistancia = v.shopDistancia
        }
        print(json.encode(shop))
    
    end
    return shop
end

local newShops = {
    id = nil,
    label = nil,
    jobname = nil,
    blipName = nil,
    blipCoords = nil,
    blipDistancia = nil,
    blipCor = nil,
    blipEnabled = nil,
    blipEscala = nil,
    MenuCoords = nil,
    MenuDistancia = nil,
    MenuEnabled = nil,
    armazemCoords = nil,
    armazemDistancia = nil,
    shopCoords = nil,
    shopDistancia = nil

}

function GetGroupGrades(group)
    local grades = {}
    for k, v in pairs(group.grades) do
        grades[#grades + 1] = {
            value = k,
            label = string.format('%s - %s', k, v.name)
        }
    end
    return grades
end

function GetBaseGroups(named)
    local jobs = exports.qbx_core:GetJobs()
    local groups = {}
    for k, v in pairs(jobs) do
        if v.type then
            local data = {
                value = k,
                label = v.label,
                grades = GetGroupGrades(v)
            }
            if named then
                groups[k] = data
            else
                groups[#groups + 1] = data
            end
        end
    end
    return groups
end

function CreatorMenu(name)
    lib.registerContext({
        id = 'menu_creator',
        menu = 'menu_gerencial',
        title = 'Gerenciar Menu',
        options = {{
            title = 'Criar novo shop',
            description = 'Crie um shop ou loja',
            icon = 'shop',
            iconAnimation = 'fade',
            arnil = true,
            onSelect = function()
                Mrishops(name)
            end
        }, {
            title = 'Listar SHOPS',
            description = 'Lista shops existentes',
            icon = 'list',
            iconAnimation = 'fade',
            arnil = true,
            onSelect = function()
                ListaMenu(name)
            end
        }}
    })
    lib.showContext('menu_creator')
end

if GetResourceState("mri_Qbox") == 'started' then
    exports['mri_Qbox']:AddManageMenu({
        title = 'SHOPS',
        description = 'Crie um shop ou loja.',
        icon = 'shop',
        iconAnimation = 'fade',
        arnil = true,
        onSelectFunction = CreatorMenu
    })
else
    lib.callback.register('mri_shops:shopmenu', function()
        CreatorMenu()
        return true
    end)
end

function Menuset(name)
    lib.registerContext({
        id = 'config_menu',
        menu = 'menu_gerencial',
        title = 'Menu Configuração',
        options = {{
            title = 'Definir a bancada',
            description = name,
            icon = 'cart-shopping',
            iconAnimation = 'fade',
            arnil = true,
            onSelect = function()
                Bancadashop(name)
            end
        }, {
            title = 'bossMenu',
            icon = 'computer',
            description = name,
            iconAnimation = 'fade',
            arnil = true,
            onSelect = function()
                Bossmenu(name)
            end
        }, {
            title = 'Armazem',
            icon = 'location-dot',
            description = name,
            iconAnimation = 'fade',
            arnil = true,
            onSelect = function()
                Armazem(name)
            end
        }, {
            title = 'blip',
            icon = 'boxes-packing',
            description = name,
            iconAnimation = 'fade',
            arnil = true,
            onSelect = function()
                MriBlips(name)
            end
        }, {
            title = 'deletar',
            icon = 'trash',
            description = name,
            iconAnimation = 'fade',
            arnil = true,
            onSelect = function()
                DeletarShop(name)
            end
        }}
    })
    lib.showContext('config_menu')
end

function Bancadashop(name)
    local shopinput = lib.inputDialog('Menu de bancadashop', {{
        type = 'number',
        label = 'digite numero de distancia',
        required = true
    }})

    if shopinput ~= nil then
        local result = exports.mri_Qbox:GetRayCoords()
        local ShopBancada = {
            shopDistancia = shopinput[1],
            shopCoords = result
        }
        print(json.encode(Shop))
        TriggerServerEvent('mri-qshops:BancadashopAtualizacaoShop', ShopBancada, name)
        -- TriggerServerEvent('mri-qshops:BancadashopAtualizacaoShop', Shop,name)
    end
end


function Armazem(name)
    local shopinput = lib.inputDialog('Menu de Armazem', {{
        type = 'number',
        label = 'digite numero de shopDistancia',
        required = true
    }, {
        type = 'checkbox',
        label = 'Use boosmenu',
        required = true
    }})

    if shopinput ~= nil then
        local result = exports.mri_Qbox:GetRayCoords()
        local Shop = {
            armazemDistancia = shopinput[1],
            armazemCoords = result
        }

        print(json.encode(Shop))
        TriggerServerEvent('mri-qshops:ArmazemAtualizacaoShop', Shop, name)

        -- print(result)
    end
end

function Bossmenu(name)
    local shopinput = lib.inputDialog('Menu de boosmenu', {{
        type = 'number',
        label = 'digite numero de Distancia',
        required = true
    }, {
        type = 'checkbox',
        label = 'Use boosmenu',
        required = true
    }})
    if shopinput ~= nil then
        local result = exports.mri_Qbox:GetRayCoords()
        local Shop = {
            MenuEnabled = shopinput[2],
            MenuDistancia = shopinput[1],
            MenuCoords = result
        }

        print(json.encode(Shop))
        TriggerServerEvent('mri-qshops:BossmenuAtualizacaoShop', Shop, name)

        -- print(result)
    end
end

function MriBlips(name)
    local shopinput = lib.inputDialog('Menu de blip', {{
        type = 'input',
        label = 'Nome do blip',
        description = 'Digite o nome do blip',
        required = true,
        min = 1,
        max = 40
    }, {
        type = 'color',
        label = 'cor do blip',
        default = '#eb4034',
        required = true
    }, {
        type = 'checkbox',
        label = 'Use Blip',
        required = true
    }, {
        type = 'number',
        label = 'digite numero de sprite',
        required = true
    }, {
        type = 'number',
        label = 'digite numero de scala',
        required = true
    }})
              
    if shopinput ~= nil then
    local result = exports.mri_Qbox:GetRayCoords()
        local Shop = {
            blipName = shopinput[1],
            blipCor = shopinput[2],
            blipEnabled = shopinput[3],
            blipDistancia = shopinput[4],
            blipEscala = shopinput[5],
            blipCoords = result
        }
        print(json.encode(Shop))
        TriggerServerEvent('mri-qshops:BlipAtualizacaoShop', Shop, name)

    end
end

function DeletarShop(name)
    local result = lib.alertDialog({
        header = "Excluir Shop",
        content = "Você tem certeza que deseja excluir " .. name .. "?",
        centered = true,
        cancel = true
    })

    if result == 'confirm' then
        TriggerServerEvent('mri-qshops:DeletarShop', name)
        TriggerServerEvent('mri-Qshops:SelectStartShop', -1)
    end
end

function Mrishops(name)
    local key = nil
    if name and name.key then
        key = name.key
    end
    local shop = {}
    if key then
        shop = Shops[key]

    else
        table.clone(newShops, shop)
    end

    local shopinput = lib.inputDialog('Menu de Criação', {{
        type = 'input',
        label = 'Nome do shop',
        description = 'Digite o nome do shop',
        required = true,
        min = 1,
        max = 32
    }, {
        type = 'select',
        label = 'Nome do emprego',
        description = 'Digite o nome do emprego',
        options = GetBaseGroups(),
        required = true,
        searchable = true
    }})
    if not shopinput then
        return
    end
    if shopinput ~= nil then
        local dadoshop = {
            label = shopinput[1],
            jobname = shopinput[2]
        }
        if not key then
            key = #Shops + 1
            Shops[key] = shop
        end
        Shops[key] = shop
        TriggerServerEvent('mri-qshops:InserirShop', dadoshop)
        TriggerServerEvent('mri-Qshops:SelectStartShop')
    else
        print('erro input')
    end
    CreatorMenu(name)
end

function ListaMenu(name)
    local shopData = {}
    local shopList = {}
    for k, v in pairs(Shops) do
        table.insert(shopList, {
            title = v.label,
            icon = 'hand',
            onSelect = function()
                Menuset(v.label)
            end
        })
    end

    table.insert(shopList, {
        title = 'Criar novo shop',
        description = 'Cria um shop',
        icon = 'cart-shopping',
        onSelect = function()
            Mrishops(name)
        end
    })

    lib.registerContext({
        id = 'Lista_menu',
        menu = 'menu_gerencial',
        title = 'Lista de SHOPS',
        options = shopList
    })
    lib.showContext('Lista_menu')
end

RegisterNetEvent("mri-Qshops:carregarshop", function()
    ShopsDataBase()
    print('Shops atualizados indo para database')
end)

