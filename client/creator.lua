
Shops = GlobalState.Shops or {}
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

function CreatorMenu()
    lib.registerContext({
        id = 'menu_creator',
        menu = 'menu_gerencial',
        title = 'Gerenciar Menu',
        options = {
            {
                title = 'Criar novo shop',
                description = 'Crie um shop ou loja',
                icon = 'shop',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    Mrishops()
                end
            },
            {
                title = 'Listar SHOPS',
                description = 'Lista shops existentes',
                icon = 'list',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ListaMenu()
                end
            }

        }
    })
    lib.showContext('menu_creator')
end

if GetResourceState("mri_Qbox") == 'started' then
    exports['mri_Qbox']:AddManageMenu({
        title            = 'SHOPS',
        description      = 'Crie um shop ou loja.',
        icon             = 'shop',
        iconAnimation    = 'fade',
        arrow            = true,
        onSelectFunction = CreatorMenu,
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
        options = {
            {
                title = 'Definir a bancada',
                description = name,
                icon = 'cart-shopping',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    Bancadashop()
                end
            },
            {
                title = 'bossMenu',
                icon = 'computer',
                description = name,
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()

                end
            },
            {
                title = 'Armazem',
                icon = 'boxes-packing',
                description = name,
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()

                end
            }
        }
    })
    lib.showContext('config_menu')
end

function Bancadashop()
local result = exports.mri_Qbox:GetRayCoords()
print (json.encode(result))
local shoplocal = {
    locations = result
}
print(json.encode(shoplocal))
TriggerServerEvent('mri-qshops:InsertShop', shoplocal)
end

function Mrishops(data)
    local shopinput = lib.inputDialog('Menu de Criação', {
        {
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
    }
    })
    if not shopinput then return end
    if shopinput ~= nil then
        local dadoshop = {
            label = shopinput[1],
            jobname = shopinput[2]
        }
        TriggerServerEvent('mri-qshops:InsertShop', dadoshop)
    else
        print('erro input')
    end
end

function ListaMenu()
    local shopData = {}
    local shopList = {} 
    for label, v in pairs(Shops) do
    table.insert(shopList, {
    title = v.label,
    icon = 'hand',
    onSelect = function()
        Menuset(label)
    end
    })
    end

    table.insert(shopList, {
        title = 'Criar novo shop',
        description = 'Cria um shop',
        icon = 'cart-shopping',
        onSelect = function()
            Mrishops()
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
RegisterNetEvent("mri_Qfarm:client:LoadFarms", function()
    Shops = GlobalState.Shops or {}
    ListaMenu()
end)
