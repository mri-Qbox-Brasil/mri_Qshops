mri_Qcolors = GlobalState.UIColors or {}
function GetGroupGrades(group)
    local grades = {}
    for k, v in pairs(group.grades) do
        grades[#grades + 1] = {
            value = k,
            label = string.format("%s - %s", k, v.name)
        }
    end
    return grades
end

function GetBaseGroups(named)
    local jobs = exports.qbx_core:GetJobs()
    local groups = {}
    for k, v in pairs(jobs) do
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
    return groups
end

local function creationMenu(args)
    local result = promise.new()
    local key =  lib.callback.await("mri_Qshops:server:GetMaxShopId", false) or 0
    result:resolve(key)
    Citizen.Await(result)
    
    local shop = {}
    local shopinput = lib.inputDialog("Criação de Negócios", {{
        type = "input",
        label = "Nome",
        description = "Digite um nome para identificar a loja",
        required = true,
        min = 1,
        max = 32
    }, {
        type = "select",
        label = "Emprego",
        description = "Selecione a permissão da loja (necessário possuir o JOB no sistema de grupos)",
        options = GetBaseGroups(),
        required = true,
        searchable = true
    }, {
        type = "select",
        label = "Interação",
        description = "Olhinho ou Apertando E, você decide!",
        options = {{
            value = "target",
            label = "Usar Target"
        }, {
            value = "drawmarker",
            label = "Usar Drawmarker"
        }},
        required = true
    }})

    if shopinput ~= nil then
        if key >= 0 then
            key = key + 1
        end
        local data = {
            label = string.format("%s%s", shopinput[1], key),
            jobname = shopinput[2],
            interaction = shopinput[3]
        }
        TriggerServerEvent("mri_Qshops:insertShop", data)
    else
        lib.showContext("menu_creator")
        return lib.notify({
            title = "Erro",
            description = "Criação cancelada.",
            type = "error"
        })
    end
    args.callback(key)
end

local Shops = {}

function mainMenu(name, key)
    local result = promise.new()
    Shops = lib.callback.await("mri_Qshops:server:GetShops", false) or {}

    local ctx = {
        id = "menu_creator",
        menu = "menu_gerencial",
        title = "Negócios",
        description = "Gerenciar Negócios",
        options = {{
            title = "Criar um novo Negócio",
            icon = "plus",
            iconAnimation = "fade",
            onSelect = creationMenu,
            args = {
                shopKey = key,
                callback = mainMenu
            }
        }, {
            progress = true
        }}
    }

    result:resolve(Shops)
    Citizen.Await(result)

    if #Shops == 0 then
        table.insert(ctx.options, {
            title = "Lista vazia",
            icon = "list",
            description = "Está faltando criatividade por aqui...",
            iconAnimation = "fade",
            disabled = true
        })
    else
        for k, v in pairs(Shops) do
            table.insert(ctx.options, {
                title = v.label,
                icon = "edit",
                onSelect = function()
                    editMenu(v.label)
                end
            })
        end
        ctx.options[#ctx.options + 1] = {
            title = "Salvar",
            description = "Salvar Alterações!",
            icon = "floppy-disk",
            iconAnimation = "fade",
            onSelect = function()
                saveShop()
            end
        }
    end

    lib.registerContext(ctx)
    lib.showContext(ctx.id)
end

function editMenu(name)
    lib.registerContext({
        id = "config_menu",
        menu = "menu_creator",
        title = "Editar",
        description = name,
        options = {{
            title = "Loja",
            description = "Defina a localização da loja.",
            icon = "cart-shopping",
            iconAnimation = "fade",
            onSelect = function()
                updateCoords(name, "shopcoords")
            end
        }, {
            title = "Estoque",
            description = "Defina a localização do estoque.",
            icon = "location-dot",
            iconAnimation = "fade",
            onSelect = function()
                updateCoords(name, "storagecoords")
            end
        }, {
            title = "Bossmenu",
            description = "Defina a localização do bossmenu.",
            icon = "computer",
            iconAnimation = "fade",
            onSelect = function()
                updateCoords(name, "menucoords")
            end
        }, {
            title = "Blip",
            description = "Defina a localização do blip (aparece no MAPA)",
            icon = "boxes-packing",
            iconAnimation = "fade",
            onSelect = function()
                editBlips(name)
            end
        }, {
            title = "Teleportar",
            description = "Ir para a localização da loja, se já estiver definida.",
            icon = "location-arrow",
            iconAnimation = "fade",
            onSelect = function()
                teleportToShop(name)
            end
        }, {
            title = "Salvar",
            description = "Salvar Alterações!",
            icon = "floppy-disk",
            iconAnimation = "fade",
            onSelect = function()
                saveShop()
            end
        }, {
            title = "Excluir",
            description = "Cuidado isso é permanente!",
            icon = "trash",
            iconColor = mri_Qcolors.danger,
            iconAnimation = "fade",
            onSelect = function()
                deleteShop(name)
            end
        }}
    })
    lib.showContext("config_menu")
end

function teleportToShop(name)
    for _, shop in pairs(Shops) do
        if shop.label == name and shop.shopcoords then
            SetEntityCoords(cache.ped, shop.shopcoords.x, shop.shopcoords.y, shop.shopcoords.z)
            lib.notify({
                title = "Teleportado!",
                description = "Você foi teleportado para a loja.",
                type = "success"
            })
            return
        end
    end

    lib.notify({
        title = "Erro",
        description = "Nenhuma coordenada definida para esta loja.",
        type = "error"
    })
end


function updateCoords(name, coordType)
    if name then
        local result = exports.mri_Qbox:GetRayCoords()
        local data = {
            label = name,
            [coordType] = result
        }
        TriggerServerEvent("mri_Qshops:UpdateShop", data)
        lib.showContext("config_menu")
    end
end

function saveShop()
    local response = {
        type = "success",
        description = "Sucesso ao Salvar!"
    }
    TriggerServerEvent("mri_Qshops:Saveshop", cache.playerId)
end

function editBlips(name)
    local shopinput = lib.inputDialog("Menu de blip", {{
        type = "input",
        label = "Nome do blip",
        description = "Digite o nome do blip",
        required = true
    }, {
        type = "number",
        label = "cor do blip",
        required = true
    }, {
        type = "checkbox",
        label = "Use Blip",
        required = true
    }, {
        type = "input",
        label = "digite numero de sprite",
        required = true
    }, {
        type = "input",
        label = "digite numero de scala",
        required = true
    }})

    if shopinput ~= nil then
        local result = GetEntityCoords(cache.ped)
        local data = {
            label = name,
            blipname = shopinput[1],
            blipcolor = shopinput[2],
            blipenabled = shopinput[3],
            blipsprite = shopinput[4],
            blipscale = shopinput[5],
            blipcoords = result
        }
        TriggerServerEvent("mri_Qshops:UpdateShop", data)
    end
    mainMenu(name)
end

function deleteShop(name)
    local result = lib.alertDialog({
        header = "Excluir Shop",
        content = "Você tem certeza que deseja excluir " .. name .. "?",
        centered = true,
        cancel = true
    })
    if result == "confirm" then
        TriggerServerEvent("mri_Qshops:deleteShop", name)
    end
    mainMenu(name)
end

if GetResourceState("mri_Qbox") == "started" then
    exports["mri_Qbox"]:AddManageMenu({
        title = "Negócios",
        description = "Crie uma nova empresa/loja gerenciada ingame.",
        icon = "shop",
        iconAnimation = "fade",
        onSelectFunction = mainMenu
    })
end
