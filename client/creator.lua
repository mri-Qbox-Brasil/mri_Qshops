local shops = {}

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

local function creatorMenu(name)
   local ctx = {
        id = 'menu_creator',
        menu = 'menu_gerencial',
        title = 'Gerenciar Menu',
        options = { {
            title = 'Criar novo shop',
            description = 'Crie um shop ou loja',
            icon = 'shop',
            iconAnimation = 'fade',
            onSelect = function()
                Mrishops(name)
            end
        }, {
            title = 'Listar shops',
            description = 'Lista shops existentes',
            icon = 'list',
            iconAnimation = 'fade',
            onSelect = function()
                ListaMenu(name)
            end
        } }
    }
    lib.registerContext(ctx)
    lib.showContext(ctx.id)
end

function Menuset(name)
    lib.registerContext({
        id = 'config_menu',
        menu = 'menu_gerencial',
        title = 'Menu Configuração',
        options = { {
            title = 'Definir a bancada',
            description = name,
            icon = 'cart-shopping',
            iconAnimation = 'fade',
            onSelect = function()
                Bancadashop(name)
            end
        }, {
            title = 'bossMenu',
            icon = 'computer',
            description = name,
            iconAnimation = 'fade',
            onSelect = function()
                Bossmenu(name)
            end
        }, {
            title = 'Armazem',
            icon = 'location-dot',
            description = name,
            iconAnimation = 'fade',
            onSelect = function()
                Armazem(name)
            end
        }, {
            title = 'blip',
            icon = 'boxes-packing',
            description = name,
            iconAnimation = 'fade',
            onSelect = function()
                MriBlips(name)
            end
        }, {
            title = 'deletar',
            icon = 'trash',
            description = name,
            iconAnimation = 'fade',
            onSelect = function()
                DeletarShop(name)
            end
        } }
    })
    lib.showContext('config_menu')
end

function Bancadashop(name)
    if name then
        local result = exports.mri_Qbox:GetRayCoords()
        shops = {
        label = name,
        shopcoords = result
        }
        TriggerServerEvent('mri_Qshops:UpdateShop', shops)
        lib.showContext('config_menu')
    end
end

function Armazem(name)
    if name then
        local result = exports.mri_Qbox:GetRayCoords()
        shops = {
            label = name,
            storagecoords = result
        }
        TriggerServerEvent('mri_Qshops:UpdateShop', shops)
        lib.showContext('config_menu')
    end
end

function Bossmenu(name)
    local shopinput = lib.inputDialog('Menu de boosmenu', { {
        type = 'checkbox',
        label = 'Use boosmenu',
        required = true
    } })
    if shopinput then
        local result = exports.mri_Qbox:GetRayCoords()
        shops = {
            label = name,
            menuenabled = shopinput[2],
            menucoords = result
        }
        TriggerServerEvent('mri_Qshops:UpdateShop', shops)
        lib.showContext('config_menu')
    end
end

function MriBlips(name)
    local shopinput = lib.inputDialog('Menu de blip', { {
        type = 'input',
        label = 'Nome do blip',
        description = 'Digite o nome do blip',
        required = true
    }, {
        type = 'number',
        label = 'cor do blip',
        required = true
    }, {
        type = 'checkbox',
        label = 'Use Blip',
        required = true
    }, {
        type = 'input',
        label = 'digite numero de sprite',
        required = true
    }, {
        type = 'input',
        label = 'digite numero de scala',
        required = true
    } })

    if shopinput ~= nil then
        local result = GetEntityCoords(cache.ped)
        shops = {
            label = name,
            blipname = shopinput[1],
            blipcolor = shopinput[2],
            blipenabled = shopinput[3],
            blipsprite = shopinput[4],
            blipscale = shopinput[5],
            blipcoords = result
        }
        TriggerServerEvent('mri_Qshops:UpdateShop', shops)
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
        TriggerServerEvent('mri_Qshops:deleteShop', name)
    end
end

function Mrishops(name)
    local shopinput = lib.inputDialog('Menu de Criação', { {
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
    }, {
        type = 'checkbox',
        label = 'Use target',
        required = true
    }, {
        type = 'checkbox',
        label = 'Use drawmaker',
        required = true
    } })

    if shopinput ~= nil then
        shops = {
            label = shopinput[1],
            jobname = shopinput[2],
            target = shopinput[3],
            drawmaker = shopinput[4]
        }
        TriggerServerEvent('mri_Qshops:insertShop', shops)
    else
        return lib.notify({ title = 'Erro', description = 'Criação cancelada.', type = 'error' })
    end
    creatorMenu(name)
end

function ListaMenu(name)
    local Shops = lib.callback.await('mri_Qshops:server:GetShops')
    
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
        title = 'Lista de shops',
        options = shopList
    })
    lib.showContext('Lista_menu')
end

if GetResourceState("mri_Qbox") == 'started' then
    exports['mri_Qbox']:AddManageMenu({
        title = 'shops',
        description = 'Crie um shop ou loja.',
        icon = 'shop',
        iconAnimation = 'fade',
        onSelectFunction = creatorMenu
    })
else
    TriggerServerEvent('mri_shops:shopmenu', function()
        creatorMenu()
        return true
    end)
end