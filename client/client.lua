function ShopsDataBaseClient(shopnews)
    Shops = GlobalState.Shops or {}
    shopnew = {}
    for k, v in pairs(Shops) do
        shopnew[#shopnew + 1] = {
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
        print("shopdataClient"..json.encode(shop))
    end
    return shopnew
end

RegisterNetEvent('wasabi_oxshops:setProductPrice', function(shop, slot)
    local input = lib.inputDialog(Strings.sell_price, {Strings.amount_input})
    local price = not input and 0 or tonumber(input[1]) --[[@as number]]
    price = price < 0 and 0 or price

    TriggerEvent('ox_inventory:closeInventory')
    TriggerServerEvent('wasabi_oxshops:setData', shop, slot, math.floor(price))
    lib.notify({
        title = Strings.success,
        description = (Strings.item_stocked_desc):format(price),
        type = 'success'
    })
end)

    CreateThread(function()
         function CreateBlip(coords, sprite, color, text, scale)
        local Shops = ShopsDataBase(v)
            for k, v in pairs(Shops) do
                local coords = v.blipCoords
                local x = coords.x
                local y = coords.y
                local z = coords.z
                local blips = vector3(x, y, z)
                local blip = AddBlipForCoord(blips)
                SetBlipSprite(blip, sprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, scale)
                SetBlipColour(blip, color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentSubstringPlayerName(text)
                EndTextCommandSetBlipName(blip)
                carregarShops()
                return blip
            end
        end
        local Shops = ShopsDataBase(v)
        for k, v in pairs(Shops) do
            if v.blip_enabled then
                CreateBlip(v.blipCoords, v.blipDistancia, v.blipCor, v.blipName, v.blipEscala)
            end
        end
    end)

    CreateThread(function()
        local textUI
        local Shops = ShopsDataBase(v)
        for k, v in pairs(Shops) do
            local armazemCoords = v.armazemCoords
            local MenuCoords = v.MenuCoords
            local shopCoords = v.shopCoords

            print(v.armazemCoords, v.armazemDistancia, v.label)
            local armazem = lib.points.new({
                coords = v.armazemCoords,
                distance = v.armazemDistancia,
                shop = v.label
            })
            local shop = lib.points.new({
                coords = v.MenuCoords,
                distance = v.MenuDistancia,
                shop = v.label
            })
            print(v.shopCoords, v.shopDistancia, v.label, 'ola mundo')   
            local bossMenu = lib.points.new({
                coords = v.shopCoords,
                distance = v.shopDistancia,
                shop = v.label
            })
        end

        function armazem:nearby()
            if not self.isClosest or PlayerData.job.name ~= self.shop then
                return
            end
            if Config.DrawMarkers then
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15,
                    30, 150, 30, 222, false, false, 0, true, false, false, false)
            end
            if self.currentDistance < self.distance then
                if not textUI then
                    lib.showTextUI('[E] - Acesssar armazem')
                    textUI = true
                end
                if IsControlJustReleased(0, 38) then
                    exports.ox_inventory:openInventory('stash', self.shop)
                end
            end
        end

        function armazem:onExit()
            if not self.isClosest then
                return
            end
            if textUI then
                lib.hideTextUI()
                textUI = nil
            end
        end

        function shop:nearby()
            if not self.isClosest then
                return
            end
            if Config.DrawMarkers then
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15,
                    30, 150, 30, 222, false, false, 0, true, false, false, false)
            end
            if self.currentDistance < self.distance then
                if not textUI then
                    lib.showTextUI("[E] - Acesssar loja")
                    textUI = true
                end
                if IsControlJustReleased(0, 38) then
                    exports.ox_inventory:openInventory('shop', {
                        type = self.shop,
                        id = 1
                    })
                end
            end
        end

        function shop:onExit()
            if not self.isClosest then
                return
            end
            if textUI then
                lib.hideTextUI()
                textUI = nil
            end
        end

        if bossMenu then
            function v.bossMenu:nearby()
                if not self.isClosest then
                    return
                end
                if IsBoss() then
                    if self.currentDistance < self.distance then
                        if Config.DrawMarkers then
                            DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                0.3, 0.2, 0.15, 30, 150, 30, 222, false, false, 0, true, false, false, false)
                        end
                        if not textUI then
                            lib.showTextUI("[E] - Acesssar menu")
                            textUI = true
                        end
                        if IsControlJustReleased(0, 38) then
                            OpenBossMenu(PlayerData.job.name)
                        end
                    end
                end
            end

            function bossMenu:onExit()
                if textUI then
                    lib.hideTextUI()
                    textUI = nil
                end
            end
        end
    end)

    RegisterNetEvent("mri-Qshops:carregarshop", function()
        ShopsDataBaseClient(Shops)
        print('Shops atualizados indo para client.lua')
    end)
