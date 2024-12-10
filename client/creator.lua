mri_Qcolors = GlobalState.UIColors or {}
local shops = {}

function GetGroupGrades(group)
	local grades = {}
	for k, v in pairs(group.grades) do
		grades[#grades + 1] = {
			value = k,
			label = string.format("%s - %s", k, v.name),
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
			grades = GetGroupGrades(v),
		}
		if named then
			groups[k] = data
		else
			groups[#groups + 1] = data
		end
	end
	return groups
end

function mainMenu(name)
	local ctx = {
		id = "menu_creator",
		menu = "menu_gerencial",
		title = "Negócios",
		description = "Gerenciar Negócios",
		options = {
			{
				title = "Criar um novo Negócio",
				icon = "plus",
				iconAnimation = "fade",
				onSelect = function()
					creationMenu(name)
				end,
			},
			{
				progress = true,
			},
		},
	}

	local Shops = lib.callback.await("mri_Qshops:server:GetShops")
	if #Shops == 0 then
		table.insert(ctx.options, {
			title = "Lista vazia",
			icon = "list",
			description = "Está faltando criatividade por aqui...",
			iconAnimation = "fade",
			disabled = true,
		})
	else
		for k, v in pairs(Shops) do
			table.insert(ctx.options, {
				title = v.label,
				icon = "edit",
				onSelect = function()
					editMenu(v.label)
				end,
			})
		end
	end
	lib.registerContext(ctx)
	lib.showContext(ctx.id)
end

function creationMenu(name)
	local shopinput = lib.inputDialog("Criação de Negócios", {
		{
			type = "input",
			label = "Nome",
			description = "Digite um nome para identificar a loja",
			required = true,
			min = 1,
			max = 32,
		},
		{
			type = "select",
			label = "Emprego",
			description = "Selecione a permissão da loja (necessário possuir o JOB no sistema de grupos)",
			options = GetBaseGroups(),
			required = true,
			searchable = true,
		},
		{
			type = "select",
			label = "Interação",
			description = "Olhinho ou Apertando E, você decide!",
			options = {
				{
					value = "target",
					label = "Usar Target",
				},
				{
					value = "drawmarker",
					label = "Usar Drawmarker",
				},
			},
			required = true,
		},
	})

	if shopinput ~= nil then
		local data = {
			label = shopinput[1],
			jobname = shopinput[2],
			interaction = shopinput[3],
		}
		TriggerServerEvent("mri_Qshops:insertShop", data)
	else
		lib.showContext("menu_creator")
		return lib.notify({ title = "Erro", description = "Criação cancelada.", type = "error" })
	end
	mainMenu(name)
end

function editMenu(name)
	lib.registerContext({
		id = "config_menu",
		menu = "menu_creator",
		title = "Editar",
		description = name,
		options = {
			{
				title = "Loja",
				description = "Defina a localização da loja.",
				icon = "cart-shopping",
				iconAnimation = "fade",
				onSelect = function()
					updateCoords(name, "shopcoords")
				end,
			},
			{
				title = "Estoque",
				description = "Defina a localização do estoque.",
				icon = "location-dot",
				iconAnimation = "fade",
				onSelect = function()
                    updateCoords(name, "storagecoords")
				end,
			},
			{
				title = "Bossmenu",
				description = "Defina a localização do bossmenu.",
				icon = "computer",
				iconAnimation = "fade",
				onSelect = function()
					updateCoords(name, "menucoords")
				end,
			},
			{
				title = "Blip",
				description = "Defina a localização do blip (aparece no MAPA)",
				icon = "boxes-packing",
				iconAnimation = "fade",
				onSelect = function()
					editBlips(name)
				end,
			},
			{
				title = "Excluir",
				description = "Cuidado isso é permanente!",
				icon = "trash",
                iconColor = mri_Qcolors.danger,
				iconAnimation = "fade",
				onSelect = function()
					deleteShop(name)
				end,
			},
		},
	})
	lib.showContext("config_menu")
end

function updateCoords(name, coordType)
	if name then
		local result = exports.mri_Qbox:GetRayCoords()
		local data = {
			label = name,
			[coordType] = result,
		}
		TriggerServerEvent("mri_Qshops:UpdateShop", data)
		lib.showContext("config_menu")
	end
end

function editBlips(name)
	local shopinput = lib.inputDialog("Menu de blip", {
		{
			type = "input",
			label = "Nome do blip",
			description = "Digite o nome do blip",
			required = true,
		},
		{
			type = "number",
			label = "cor do blip",
			required = true,
		},
		{
			type = "checkbox",
			label = "Use Blip",
			required = true,
		},
		{
			type = "input",
			label = "digite numero de sprite",
			required = true,
		},
		{
			type = "input",
			label = "digite numero de scala",
			required = true,
		},
	})

	if shopinput ~= nil then
		local result = GetEntityCoords(cache.ped)
		local data = {
			label = name,
			blipname = shopinput[1],
			blipcolor = shopinput[2],
			blipenabled = shopinput[3],
			blipsprite = shopinput[4],
			blipscale = shopinput[5],
			blipcoords = result,
		}
		TriggerServerEvent("mri_Qshops:UpdateShop", data)
	end
end

function deleteShop(name)
	local result = lib.alertDialog({
		header = "Excluir Shop",
		content = "Você tem certeza que deseja excluir " .. name .. "?",
		centered = true,
		cancel = true,
	})
	if result == "confirm" then
		TriggerServerEvent("mri_Qshops:deleteShop", name)
	end
end

if GetResourceState("mri_Qbox") == "started" then
	exports["mri_Qbox"]:AddManageMenu({
		title = "Negócios",
		description = "Crie uma nova empresa/loja gerenciada ingame.",
		icon = "shop",
		iconAnimation = "fade",
		onSelectFunction = mainMenu,
	})
end
