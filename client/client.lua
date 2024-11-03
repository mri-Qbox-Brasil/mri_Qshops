Shops = {}
---@diagnostic disable: undefined-global
RegisterNetEvent('mri_Qshops:setProductPrice', function(shop, slot)
    local input = lib.inputDialog(Strings.sell_price, { Strings.amount_input })
    local price = not input and 0 or tonumber(input[1]) --[[@as number]]
    price = price < 0 and 0 or price

    TriggerEvent('ox_inventory:closeInventory')
    TriggerServerEvent('mri_Qshops:setData', shop, slot, math.floor(price))
    lib.notify({
        title = Strings.success,
        description = (Strings.item_stocked_desc):format(price),
        type = 'success'
    })
end)


local function createBlip(blipcoords,blipName,blipSprite,blipCor,blipscale)
    local text = blipName
    local blip = AddBlipForCoord(blipcoords.x, blipcoords.y, blipcoords.z)
    --local blip = AddBlipForCoord(blipconfig.blipcoords)
    SetBlipSprite(blip,blipSprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipscale)
    SetBlipColour(blip, blipCor)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function mriLoadsShops(Shops)
    for k, v in pairs(Shops) do
        print(json.encode(Shops), 'mriLoadsShops- banco de dados')
        print(json.encode(v.target), 'mriLoadsShops')
        print(json.encode(v.MenuEnabled), 'mriLoadsShops')
        print(json.encode(v.armazemCoords), 'mriLoadsShops')
        if v.target then
            print(json.encode(v.shopCoords), 'mriLoadsShops')
            exports.ox_target:addSphereZone({
                coords = v.shopCoords,
                radius = 0.5,
                debug = false,
                options = { {
                    label = 'Accessar Shop',
                    icon = 'fa-solid fa-shop',
                    onSelect = function()
                        exports.ox_inventory:openInventory('stash', v.jobname)
                    end
                } }
            })
        end
        if v.blipEnabled then
            print(json.encode(v.blipName), 'blipss')
            createBlip(v.blipcoords,v.blipName,v.blipSprite,v.blipCor,v.blipscale)
            if v.MenuEnabled == nil then
                print('passei por aqui blip não foi')
            end
        end
        if v.target then
            exports.ox_target:addSphereZone({
                coords = v.MenuCoords,
                radius = 0.5,
                debug = false,
                options = { {
                    label = 'Accessar Menu',
                    icon = 'fa-solid fa-user-group',
                    onSelect = function()
                        exports.qbx_management:OpenBossMenu(PlayerData.job.name)
                    end,
                    canInteract = function()
                        return IsBoss()
                    end
                } }
            })
        end

        if v.target then
            exports.ox_target:addSphereZone({
                coords = v.armazemCoords,
                radius = 0.5,
                debug = false,
                options = { {
                    label = 'Accessar Amazem',
                    icon = 'fa-solid fa-box',
                    onSelect = function()
                        exports.ox_inventory:openInventory('shop', {
                            type = v.label,
                            id = 1
                        })
                    end
                } }
            })
        end
    end
end

RegisterNetEvent('mri_Qshops:updateshop')
AddEventHandler('mri_Qshops:updateshop', function(shops)
    Shops = shops
    mriLoadsShops(Shops)
end)
