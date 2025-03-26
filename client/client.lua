local points = {}
local pointsTarget = {}

RegisterNetEvent("mri_Qshops:setProductPrice", function(shop, slot)
    local input = lib.inputDialog(locale("sell_price"), {locale("price_value")})
    local price = not input and 0 or tonumber(input[1])
    price = price < 0 and 0 or price

    TriggerEvent("ox_inventory:closeInventory")
    TriggerServerEvent("mri_Qshops:setData", shop, slot, math.floor(price))
    lib.notify({
        title = locale("success"),
        description = (locale("item_stocked_desc")):format(price),
        type = "success"
    })
end)

local createdBlips = {}

local function removeAllBlips()
    if createdBlips then
        for _, blip in ipairs(createdBlips) do
            RemoveBlip(blip)
        end
    end
end

local function createBlip(blipcoords, blipname, blipsprite, blipcolor, blipscale,label)
    local blip = AddBlipForCoord(blipcoords.x, blipcoords.y, blipcoords.z)
    SetBlipSprite(blip, blipsprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipscale)
    SetBlipColour(blip, blipcolor)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(blipname)
    EndTextCommandSetBlipName(blip)
    table.insert(createdBlips, blip)
    return blip
end

local function updateShopsBlips(shops)
    removeAllBlips()
    for _, shop in ipairs(shops) do
        if shop.blipdata and shop.shopcoords then
            local coords = vector3(shop.blipdata.blipcoords.x, shop.blipdata.blipcoords.y, shop.blipdata.blipcoords.z)
            createBlip(coords, shop.blipdata.blipname, tonumber(shop.blipdata.blipsprite),
                tonumber(shop.blipdata.blipcolor), tonumber(shop.blipdata.blipscale),shop.label)
        end
    end
end

local removeTarget = nil or {}
local function clearPointsTarget()
    if pointsTarget ~= {} then
        for k, v in pairs(pointsTarget) do
            exports.ox_target:removeZone(k)
        end
    end
    pointsTarget = {}
    Citizen.Wait(0)
end

local function addTarget(coords, label, name, type, job)
    local icon = ""
    if not coords then
        return
    end
    if type == "stash" then
        icon = "fa-solid fa-box"
    elseif type == "shop" then
        icon = "fa-solid fa-cart-shopping"
    elseif type == "bossMenu" then
        icon = "fa-solid fa-crown"
    end
    pointsTarget[label] = nil or {}
    pointsTarget[label] = exports.ox_target:addSphereZone({
        coords = coords,
        name = label,
        options = {
            icon = icon,
            job = job,
            label = string.format("Abrir %s", name),
            onSelect = function()
                if interaction == "drawmarker" then
                    return
                end
                if type == "bossMenu" and IsBoss() then
                    if Jobname() ~= job then
                        return
                    end
                    OpenBossMenu(Jobname())
                elseif type == "shop" then
                    exports.ox_inventory:openInventory("shop", {
                        type = label,
                        id = 1
                    })
                elseif type == "stash" then
                    debug("Tentou abrir stash: ".. job .. " " .. label)
                    if Jobname() ~= job then
                        return
                    end

                    local Jobname = Jobname()
                    debug("Jobname: " .. Jobname .. " job: " .. job)
                    exports.ox_inventory:openInventory("stash", label)
                end
            end
        }
    })
end

local function removePoints()
    for label, pointData in pairs(points) do
        if pointData.stash then
            pointData.stash:remove()
        end
        if pointData.shop then
            pointData.shop:remove()
        end
        if pointData.bossMenu then
            pointData.bossMenu:remove()
        end
    end
    Citizen.Wait(0)
end

local function MenuTarget(shops)
    if not shops then
        return
    end

    for k, v in pairs(shops) do
        if v.label and v.interaction == "target" then
            local armazemCoords =
                v.storagecoords and vector3(v.storagecoords.x, v.storagecoords.y, v.storagecoords.z) or nil
            local shopCoords = v.shopcoords and vector3(v.shopcoords.x, v.shopcoords.y, v.shopcoords.z) or nil
            local menuCoords = v.menucoords and vector3(v.menucoords.x, v.menucoords.y, v.menucoords.z) or nil
            addTarget(armazemCoords, v.label, "Estoque", "stash", v.jobname)
            addTarget(shopCoords, v.label, "Loja", "shop", v.jobname, v.id)
            addTarget(menuCoords, v.label, "Bossmenu", "bossMenu", v.jobname)
        end
    end
end

function mriMenuShops(Shops)
    local textUI = {}

    for k, v in pairs(Shops) do
        if v.interaction == "drawmarker" and v.label then
            local id = v.id
            local interaction = v.interaction
            local armazemCoords =
                v.storagecoords and vector3(v.storagecoords.x, v.storagecoords.y, v.storagecoords.z) or nil
            local shopCoords = v.shopcoords and vector3(v.shopcoords.x, v.shopcoords.y, v.shopcoords.z) or nil
            local menuCoords = v.menucoords and vector3(v.menucoords.x, v.menucoords.y, v.menucoords.z) or nil
            if not points[v.label] then
                points[v.label] = {}
            end
            if armazemCoords then
                points[v.label].stash = lib.points.new({
                    coords = armazemCoords,
                    distance = 2.0,
                    shop = v.label,
                    job = v.jobname,
                    interaction = interaction
                })
            end

            if shopCoords then
                points[v.label].shop = lib.points.new({
                    coords = shopCoords,
                    distance = 2.0,
                    shop = v.label,
                    job = v.jobname,
                    interaction = interaction
                })
            end

            if menuCoords then
                points[v.label].bossMenu = lib.points.new({
                    coords = menuCoords,
                    distance = 2.0,
                    shop = v.label,
                    job = v.jobname,
                    interaction = interaction
                })
            end
        end
        for _, v in pairs(points) do
            if not v.stash then
                return
            end
            function v.stash:nearby()
                if not self.isClosest or Jobname() ~= self.job then
                    return
                end
                if v.blipenabled then
                    DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2,
                        0.15, 30, 150, 30, 222, false, false, 0, true, false, false, false)
                end
                if self.currentDistance < self.distance then
                    if not textUI then
                        lib.showTextUI("[E] - Abrir Estoque", {
                            icon = "box"
                        })
                        textUI = true
                    end
                    if IsControlJustReleased(0, 38) then
                        exports.ox_inventory:openInventory("stash", self.shop)
                    end
                end
            end

            function v.stash:onExit()
                if not self.isClosest then
                    return
                end
                if textUI then
                    lib.hideTextUI()
                    textUI = nil
                end
            end

            function v.shop:nearby()
                if not self.isClosest then
                    return
                end

                if v.interaction == "drawmarker" then
                    DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2,
                        0.15, 30, 150, 30, 222, false, false, 0, true, false, false, false)
                end
                if self.currentDistance < self.distance then
                    if not textUI then
                        lib.showTextUI("[E] - Abrir Loja", {
                            icon = "shop"
                        })
                        textUI = true
                    end
                    if IsControlJustReleased(0, 38) then
                        exports.ox_inventory:openInventory("shop", {
                            type = self.shop,
                            id = 1
                        })
                    end
                end
            end

            function v.shop:onExit()
                if not self.isClosest then
                    return
                end
                if textUI then
                    lib.hideTextUI()
                    textUI = nil
                end
            end

            if v.bossMenu then
                function v.bossMenu:nearby()
                    if not self.isClosest then
                        return
                    end
                    if IsBoss() then
                        if self.currentDistance < self.distance then
                            if v.interaction == "drawmarker" then
                                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                    0.3, 0.2, 0.15, 30, 150, 30, 222, false, false, 0, true, false, false, false)
                            end
                            if not textUI then
                                lib.showTextUI("[E] - Bossmenu", {
                                    icon = "crown"
                                })
                                textUI = true
                            end
                            if IsControlJustReleased(0, 38) then
                                OpenBossMenu(Jobname())
                            end
                        end
                    end
                end

                function v.bossMenu:onExit()
                    if textUI then
                        lib.hideTextUI()
                        textUI = nil
                    end
                end
            end
        end
    end
end
exports("mriMenuShops", mriMenuShops)

RegisterNetEvent("mri_Qshops:updatesDBshop", function(Shops)
    local Shops = Shops
    if not Shops then
        return
    end
    removePoints()
    clearPointsTarget()
    mriMenuShops(Shops)
    MenuTarget(Shops)
    updateShopsBlips(Shops)
end)
