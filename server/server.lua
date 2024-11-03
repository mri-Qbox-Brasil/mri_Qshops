local shops = exports.mri_Qshops:GetShops()
local swapHook, buyHook
if not IsESX() and not IsQBCore() then
	error('Framework not detected')
end

lib.callback.register('mri_Qshops:server:registerStash', function(source, id, label, slots, weight)
	return exports.ox_inventory:RegisterStash(id, label, slots, weight)
end)

CreateThread(function()
	while GetResourceState('ox_inventory') ~= 'started' do Wait(400) end
   print(json.encode(shops), 'server.lua shops')
	for k, v in pairs(shops) do
		print(json.encode(v.jobname), 'server.lua')
		local stash = {
			id = v.jobname,
			label = v.label,
			slots = 50,
			weight = 100,
		}
		print(stash.label, stash.slots, stash.weight * 1000, true)
		exports.ox_inventory:RegisterStash(v.jobname, stash.label, stash.slots, stash.weight * 1000)
		local items = exports.ox_inventory:GetInventoryItems(stash.id, false)
		local stashItems = {}
		if items and items ~= {} then
			for _, v2 in pairs(items) do
				if v2 and v2.name then
					stashItems[#stashItems + 1] = { name = v2.name, metadata = v2.metadata, count = v2.count, price = (v2.metadata.price or 0) }
				end
			end

			exports.ox_inventory:RegisterShop(v.jobname, {
				name = v.label,
				inventory = stashItems,
				locations = {
					v.shopCoords,
				}
			})
		end
	end

	swapHook = exports.ox_inventory:registerHook('swapItems', function(payload)
		print(json.encode(shops), 'server.lua')
		for k, v in pairs(shops) do
			if payload.fromInventory == v.jobname then
				TriggerEvent('mri_qshops:refreshShop', v.jobname)
			elseif payload.toInventory == v.jobname and tonumber(payload.fromInventory) then
				TriggerClientEvent('mri_Qshops:setProductPrice', payload.fromInventory, v.jobname, payload.toSlot)
			end
		end
	end, {})

	buyHook = exports.ox_inventory:registerHook('buyItem', function(payload)
		local metadata = payload.metadata
		if metadata.shopData then
			exports.ox_inventory:RemoveItem(metadata.shopData.shop, payload.itemName, payload.count)
			AddMoney(metadata.shopData.shop, metadata.shopData.price)
		end
	end, {})
end)

RegisterNetEvent('mri_qshops:refreshShop', function(shop)
	Wait(250)
	local items = exports.ox_inventory:GetInventoryItems(shop, false)
	local stashItems = {}
	for _, v in pairs(items) do
		if v and v.name then
			local metadata = v.metadata
			if metadata.shopData then
				stashItems[#stashItems + 1] = { name = v.name, metadata = metadata, count = v.count, price = metadata
				.shopData.price }
			end
		end
	end
	for k, v in pairs(shops) do
		exports.ox_inventory:RegisterShop(shop, {
			name = v.label,
			inventory = stashItems,
			locations = {
				v.shopCoords,
			}
		})
	end
end)

RegisterNetEvent('mri_Qshops:setData', function(shop, slot, price)
	local item = exports.ox_inventory:GetSlot(shop, slot)
	if not item then return end

	local metadata = item.metadata
	metadata.shopData = {
		shop = shop,
		price = price
	}

	exports.ox_inventory:SetMetadata(shop, slot, metadata)
	TriggerEvent('mri_qshops:refreshShop', shop)
end)

if GetResourceState('mri_Qbox') ~= 'started' then
	lib.addCommand('shopmenu', {
		help = 'menu de shop menu',
	}, function(source, args, raw)
		lib.callback('mri_shops:shopmenu', source)
	end)
end
