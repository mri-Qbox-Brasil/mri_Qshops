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


local function createBlip(blipcoords, blipName, blipSprite, blipCor, blipscale)
    local text = blipName
    local blip = AddBlipForCoord(blipcoords.x, blipcoords.y, blipcoords.z)
    --local blip = AddBlipForCoord(blipconfig.blipcoords)
    SetBlipSprite(blip, blipSprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipscale)
    SetBlipColour(blip, blipCor)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function mriMenuShops(Shops)
    local textUI, points = nil, {}
    while not PlayerLoaded do Wait(500) end
    for k, v in pairs(Shops) do
        local job = v.jobname
        local armazemcoords = v.armazemCoords and vector3(v.armazemCoords.x, v.armazemCoords.y, v.armazemCoords.z) or nil
        local shopcoords = v.shopCoords and vector3(v.shopCoords.x, v.shopCoords.y, v.shopCoords.z) or nil
        local menucoords = v.MenuCoords and vector3(v.MenuCoords.x, v.MenuCoords.y, v.MenuCoords.z) or nil
        if not points[job] then points[job] = {} end

        if armazemcoords then
            points[job].stash = lib.points.new({
                coords = armazemcoords,
                distance = 4.0,
                shop = job
            })
        end
    
        if v.shopCoords then
            points[job].shop = lib.points.new({
                coords = shopcoords,
                distance = 4.0,
                shop = job
            })
        end

        if v.MenuCoords then
            points[job].bossMenu = lib.points.new({
                coords = menucoords,
                distance = 3.0,
                shop = job
            })
        end
    end

    for _, v in pairs(points) do
        if not v.stash then return end
        function v.stash:nearby()
            if not self.isClosest or PlayerData.job.name ~= self.shop then return end
            if v.blipEnabled then
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15,
                    30, 150, 30, 222, false, false, 0, true, false, false, false)
            end
            if self.currentDistance < self.distance then
                if not textUI then
                    lib.showTextUI('[E] - Acessar Armazem')
                    textUI = true
                end
                if IsControlJustReleased(0, 38) then
                    exports.ox_inventory:openInventory('stash', self.shop)
                end
            end
        end

        function v.stash:onExit()
            if not self.isClosest then return end
            if textUI then
                lib.hideTextUI()
                textUI = nil
            end
        end

        function v.shop:nearby()
            if not self.isClosest then return end
            if Config.DrawMarkers then
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15,
                    30, 150, 30, 222, false, false, 0, true, false, false, false)
            end
            if self.currentDistance < self.distance then
                if not textUI then
                    lib.showTextUI('[E] - Acessar loja')
                    textUI = true
                end
                if IsControlJustReleased(0, 38) then
                    exports.ox_inventory:openInventory('shop', { type = self.shop, id = 1 })
                end
            end
        end

        function v.shop:onExit()
            if not self.isClosest then return end
            if textUI then
                lib.hideTextUI()
                textUI = nil
            end
        end

        --if v?.bossMenu then
        function v.bossMenu:nearby()
            if not self.isClosest then return end
            if IsBoss() then
                if self.currentDistance < self.distance then
                    if Config.DrawMarkers then
                        DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2,
                            0.15, 30, 150, 30, 222, false, false, 0, true, false, false, false)
                    end
                    if not textUI then
                        lib.showTextUI('Acessar Boss Menu')
                        textUI = true
                    end
                    if IsControlJustReleased(0, 38) then
                        OpenBossMenu(PlayerData.job.name)
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

RegisterNetEvent('mri_Qshops:updatesDBshop')
AddEventHandler('mri_Qshops:updatesDBshop', function(shops)
    Shops = shops
    if Shops == nil then
        return
    end
    mriMenuShops(Shops)  
end)
