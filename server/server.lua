local swapHook, buyHook = {}, {}
if not IsESX() and not IsQBCore() then
    error("Framework not detected")
end

lib.callback.register("mri_Qshops:server:GetShops", function()
    Citizen.Wait(0)
    return exports.mri_Qshops:GetShops()
end)

local function RemoveHooks()
    if not swapHook or not buyHook then
        return
    end

    for i = 1, #buyHook do
        exports.ox_inventory:removeHooks(buyHook[i])
    end

    for i = 1, #swapHook do
        exports.ox_inventory:removeHooks(swapHook[i])
    end
end

RegisterNetEvent("mri_Qshops:server:createHooks", function()
    RemoveHooks()

    if not swapHook or not buyHook then
        swapHook, buyHook = {}, {}
    end
    local job = ""
    local shops = exports.mri_Qshops:GetShops()

    while GetResourceState("ox_inventory") ~= "started" do
        Wait(400)
    end
    for k, v in pairs(shops) do
        local stash = {
            id = v.label,
            label = v.label,
            slots = 50,
            weight = 100
        }
        exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight * 1000)
		debug("RegisterStash: " .. stash.id .. " " .. stash.label .. " " .. stash.slots .. " " .. stash.weight)

        local items = exports.ox_inventory:GetInventoryItems(stash.id, false)
        local stashItems = {}
        if items and items ~= {} then
            for _, v2 in pairs(items) do
                if v2 and v2.name then
                    stashItems[#stashItems + 1] = {
                        name = v2.name,
                        metadata = v2.metadata,
                        count = v2.count,
                        price = (v2.metadata.shopData and v2.metadata.shopData.price or 0)
                    }
                end
            end
            exports.ox_inventory:RegisterShop(stash.id, {
                name = v.label,
                inventory = stashItems,
                locations = {v.shopcoords}
            })
            debug("Registerd Shop: ".. stash.id)

        end
    end

    swapHook[#swapHook + 1] = exports.ox_inventory:registerHook("swapItems", function(payload)
        for k, v in pairs(shops) do
            local stash = {
                id = v.label,
                label = v.label,
                slots = 50,
                weight = 100
            }
            job = v.jobname
            if payload.fromInventory == stash.id then
                TriggerEvent("mri_qshops:refreshShop", stash.id)
            elseif payload.toInventory == stash.id and tonumber(payload.fromInventory) then
                TriggerClientEvent("mri_Qshops:setProductPrice", payload.fromInventory, stash.id, payload.toSlot, job)
            end
        end
    end, {})

    buyHook[#buyHook + 1] = exports.ox_inventory:registerHook("buyItem", function(payload)
        local metadata = payload.metadata
        if metadata.shopData then
            exports.ox_inventory:RemoveItem(metadata.shopData.shop, payload.itemName, payload.count)
            if not metadata.shopData and metadata.shopData.job then return end
            local total = metadata.shopData.price * payload.count
            AddMoney(metadata.shopData.job, total, string.format("Venda de x%s %s por R$%s",
                payload.count, payload.itemName, metadata.shopData.price))
        end
    end, {})
end)

RegisterNetEvent("mri_qshops:refreshShop", function(shop)
    local shops = exports.mri_Qshops:GetShops()

    local items = exports.ox_inventory:GetInventoryItems(shop, false)
    local stashItems = {}
    for _, v in pairs(items) do
        if v and v.name then
            local metadata = v.metadata
            if metadata.shopData then
                stashItems[#stashItems + 1] = {
                    name = v.name,
                    metadata = metadata,
                    count = v.count,
                    price = metadata.shopData.price
                }
            end
        end
    end
    for k, v in pairs(shops) do
		debug("RegisterShop: ", v.label)
        exports.ox_inventory:RegisterShop(shop, {
            name = v.label,
            inventory = stashItems,
            locations = {v.shopcoords}
        })
    end
end)

RegisterNetEvent("mri_Qshops:setData", function(shop, slot, price, job)
    local item = exports.ox_inventory:GetSlot(shop, slot)
    if not item then
        return
    end
    local metadata = item.metadata
    metadata.shopData = {
        shop = shop,
        price = price,
        job = job
    }

    exports.ox_inventory:SetMetadata(shop, slot, metadata)
    TriggerEvent("mri_qshops:refreshShop", shop)
end)

if GetResourceState("mri_Qbox") ~= "started" then
    lib.addCommand("shopmenu", {
        help = "menu de shop menu"
    }, function(source, args, raw)
        lib.callback("mri_shops:shopmenu", source)
    end)
end
