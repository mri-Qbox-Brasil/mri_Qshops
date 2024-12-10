Shops = {}

RegisterNetEvent("mri_Qshops:setProductPrice", function(shop, slot)
	local input = lib.inputDialog(locale("sell_price"), { locale("price_value") })
	local price = not input and 0 or tonumber(input[1])
	price = price < 0 and 0 or price

	TriggerEvent("ox_inventory:closeInventory")
	TriggerServerEvent("mri_Qshops:setData", shop, slot, math.floor(price))
	lib.notify({
		title = locale("success"),
		description = (locale("item_stocked_desc")):format(price),
		type = "success",
	})
end)

local function createBlip(blipcoords, blipname, blipsprite, blipcolor, blipscale)
	local text = blipname
	local blip = AddBlipForCoord(blipcoords.x, blipcoords.y, blipcoords.z)
	SetBlipSprite(blip, blipsprite)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, blipscale)
	SetBlipColour(blip, blipcolor)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)
	return blip
end

local function mriMenuShops(Shops)
	local textUI, points = nil, {}
	for k, v in pairs(Shops) do
		local job = v.jobname
		local interaction = v.interaction
		local armazemcoords = v.storagecoords and vector3(v.storagecoords.x, v.storagecoords.y, v.storagecoords.z)
			or nil
		local shopcoords = v.shopcoords and vector3(v.shopcoords.x, v.shopcoords.y, v.shopcoords.z) or nil
		local menucoords = v.menucoords and vector3(v.menucoords.x, v.menucoords.y, v.menucoords.z) or nil
		if not points[job] then
			points[job] = {}
		end

		if armazemcoords then
			points[job].stash = lib.points.new({
				coords = armazemcoords,
				distance = 4.0,
				shop = v.label,
				job = job,
				interaction = interaction,
			})
		end

		if v.shopcoords then
			points[job].shop = lib.points.new({
				coords = shopcoords,
				distance = 4.0,
				shop = v.label,
				job = job,
				interaction = interaction,
			})
		end

		if v.menucoords then
			points[job].bossMenu = lib.points.new({
				coords = menucoords,
				distance = 3.0,
				shop = v.label,
				job = job,
				interaction = interaction,
			})
		end
	end

	for _, v in pairs(points) do
		if not v.stash then
			return
		end
		function v.stash:nearby()
			if not self.isClosest or PlayerData.job.name ~= self.job then
				return
			end
			if v.blipenabled then
				DrawMarker(
					2,
					self.coords.x,
					self.coords.y,
					self.coords.z,
					0.0,
					0.0,
					0.0,
					0.0,
					0.0,
					0.0,
					0.3,
					0.2,
					0.15,
					30,
					150,
					30,
					222,
					false,
					false,
					0,
					true,
					false,
					false,
					false
				)
			end
			if self.currentDistance < self.distance then
				if not textUI then
					lib.showTextUI("[E] - Abrir Estoque", {
						icon = "box",
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
				DrawMarker(
					2,
					self.coords.x,
					self.coords.y,
					self.coords.z,
					0.0,
					0.0,
					0.0,
					0.0,
					0.0,
					0.0,
					0.3,
					0.2,
					0.15,
					30,
					150,
					30,
					222,
					false,
					false,
					0,
					true,
					false,
					false,
					false
				)
			end
			if self.currentDistance < self.distance then
				if not textUI then
					lib.showTextUI("[E] - Abrir Loja", {
						icon = "shop",
					})
					textUI = true
				end
				if IsControlJustReleased(0, 38) then
					exports.ox_inventory:openInventory("shop", { type = self.shop, id = 1 })
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

		function v.bossMenu:nearby()
			if not self.isClosest then
				return
			end
			if IsBoss() then
				if self.currentDistance < self.distance then
					if v.interaction == "drawmarker" then
						DrawMarker(
							2,
							self.coords.x,
							self.coords.y,
							self.coords.z,
							0.0,
							0.0,
							0.0,
							0.0,
							0.0,
							0.0,
							0.3,
							0.2,
							0.15,
							30,
							150,
							30,
							222,
							false,
							false,
							0,
							true,
							false,
							false,
							false
						)
					end
					if not textUI then
						lib.showTextUI("[E] - Bossmenu", {
							icon = "crown",
						})
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
exports("mriMenuShops", mriMenuShops)

RegisterNetEvent("mri_Qshops:updatesDBshop", function(shops)
	Shops = shops
	if Shops == nil then
		return
	end
	mriMenuShops(Shops)
end)
