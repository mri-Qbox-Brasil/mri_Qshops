-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local swapHook, buyHook
Shops = GlobalState.Shops or {}
if not IsESX() and not IsQBCore() then
	error('Framework not detected')
end

CreateThread(function()
	if IsESX() then
		for k in pairs(Config.Shops) do
			TriggerEvent('esx_society:registerSociety', k, k, 'society_'..k, 'society_'..k, 'society_'..k, {type = 'public'})
		end
	end
end)

local function dispatchEvents(source, response)
	GlobalState:set('Shops', Shops, true)
	LoadShops(true)
	Wait(2000)
	TriggerClientEvent('mri_Qshops:client:LoadSelect', -1)
end
CreateThread(function()
	while GetResourceState('ox_inventory') ~= 'started' do Wait(1000) end

	for k, v in pairs(Config.Shops) do
		local stash = {
			id = k,
			label = v.label..' '..Strings.inventory,
			slots = 50,
			weight = 100000,
		}
		exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight)
		local items = exports.ox_inventory:GetInventoryItems(k, false)
		local stashItems = {}
		if items and items ~= {} then
			for _, v2 in pairs(items) do
				if v2 and v2.name then
					stashItems[#stashItems + 1] = { name = v2.name, metadata = v2.metadata, count = v2.count, price = (v2.metadata.shopData.price or 0) }
				end
			end

			exports.ox_inventory:RegisterShop(k, {
				name = v.label,
				inventory = stashItems,
				locations = {
					v.locations.shop.coords,
				}
			})
		end
	end

	swapHook = exports.ox_inventory:registerHook('swapItems', function(payload)
		for k in pairs(Config.Shops) do
			if payload.fromInventory == k then
				TriggerEvent('wasabi_oxshops:refreshShop', k)
			elseif payload.toInventory == k and tonumber(payload.fromInventory) then
				TriggerClientEvent('wasabi_oxshops:setProductPrice', payload.fromInventory, k, payload.toSlot)
			end
		end
	end, {})

	buyHook = exports.ox_inventory:registerHook('buyItem', function(payload)
		local metadata = payload.metadata
		if metadata?.shopData then
			exports.ox_inventory:RemoveItem(metadata.shopData.shop, payload.itemName, payload.count)
			AddMoney(metadata.shopData.shop, metadata.shopData.price)
		end
	end, {})
end)

RegisterNetEvent('wasabi_oxshops:refreshShop', function(shop)
	Wait(250)
	local items = exports.ox_inventory:GetInventoryItems(shop, false)
	local stashItems = {}
	for _, v in pairs(items) do
		if v and v.name then
			local metadata = v.metadata
			if metadata?.shopData then
				stashItems[#stashItems + 1] = { name = v.name, metadata = metadata, count = v.count, price = metadata.shopData.price }
			end
		end
	end

	exports.ox_inventory:RegisterShop(shop, {
		name = Config.Shops[shop].label,
		inventory = stashItems,
		locations = {
			Config.Shops[shop].locations.shop.coords,
		}
	})
end)

RegisterNetEvent('wasabi_oxshops:setData', function(shop, slot, price)
	local item = exports.ox_inventory:GetSlot(shop, slot)
	if not item then return end

	local metadata = item.metadata
	metadata.shopData = {
		shop = shop,
		price = price
	}

	exports.ox_inventory:SetMetadata(shop, slot, metadata)
	TriggerEvent('wasabi_oxshops:refreshShop', shop)
end)

 function LoadShops(isStarting)
    if isStarting then
        DB.CreateTable()
    end
end

AddEventHandler('onResourceStart', function(resourceName)
  Wait(200)
    if (GetCurrentResourceName() == resourceName) then
	local sql = 'SELECT * FROM mri_qshops'
	local result = MySQL.Sync.fetchAll(sql, {})
	local shops = {}
    if result and #result > 0 then
	for _, row in ipairs(result) do
	local sho = {
		label = row.label,
		jobname = row.jobname,
		blip_coords = row.blip_coords,
		blip_sprite = row.blip_sprite ,
		blip_color = row.blip_color ,
		blip_enabled = row.blip_enabled,
		bossMenu_coords = row.bossMenu_coords ,
	    bossMenu_range = row.bossMenu_range ,
		bossMenu_enabled = row.bossMenu_enabled ,
		locations = row.locations ,
		range = row.range ,
		shop_coords = row.shop_coords ,
		shop_range = row.shop_range ,
	}
	shops[_] = sho
	end
	end
	Shops = shops
	dispatchEvents(source)
    end
end)
if GetResourceState('mri_Qbox') ~= 'started' then
	lib.addCommand('shopmenu',{
		help = 'menu de shop menu',
	}, function(source, args,  raw)	
       lib.callback('mri_shops:shopmenu', source)
   end)
end