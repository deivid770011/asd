ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_phone:registerNumber', 'police', 'Alerte police', true, true) --- Si vous avez un GCPHONE

TriggerEvent('esx_society:registerSociety', 'police', 'police', 'society_police', 'society_police', 'society_police', {type = 'public'})

ESX.RegisterServerCallback('rPolice:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('rPolice:getStockItem')
AddEventHandler('rPolice:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showAdvancedNotification', _source, 'Coffre', '~o~Informations~s~', 'Vous avez retiré ~r~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _source, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)

ESX.RegisterServerCallback('rPolice:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

RegisterNetEvent('rPolice:putStockItems')
AddEventHandler('rPolice:putStockItems', function(itemName, count)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez déposé ~g~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)

RegisterNetEvent('rPolice:arsenal')
AddEventHandler('rPolice:arsenal', function(item,price)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xMoney = xPlayer.getMoney()

    if xMoney >= price then
        xPlayer.removeMoney(price)
        xPlayer.addWeapon(item, Config.Nombredeballe)
        TriggerClientEvent('esx:showNotification', _source, "~g~Achats~w~ effectué !")
    else
         TriggerClientEvent('esx:showNotification', _source, "Vous n'avez assez ~r~d\'argent")
    end
end)

RegisterNetEvent('rPolice:arsenalvide')
AddEventHandler('rPolice:arsenalvide', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	for k,v in pairs(Arsenal.Police) do
		xPlayer.removeWeapon(string.upper(v.Name))
	end
	TriggerClientEvent('esx:showNotification', source, "Vous avez posé tous vos armes")
end)

RegisterServerEvent('police:PriseEtFinservice')
AddEventHandler('police:PriseEtFinservice', function(PriseOuFin)
	local _source = source
	local _raison = PriseOuFin
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()
	local name = xPlayer.getName(_source)

	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'police' then
			TriggerClientEvent('police:InfoService', xPlayers[i], _raison, name)
		end
	end
end)

RegisterServerEvent('renfort')
AddEventHandler('renfort', function(coords, raison)
	local _source = source
	local _raison = raison
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'police' then
			TriggerClientEvent('renfort:setBlip', xPlayers[i], coords, _raison)
		end
	end
end)


ESX.RegisterServerCallback('rPolice:getVehicleInfos', function(source, cb, plate)

	MySQL.Async.fetchAll('SELECT owner, vehicle FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)

		local retrivedInfo = {
			plate = plate
		}

		if result[1] then
			MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier',  {
				['@identifier'] = result[1].owner
			}, function(result2)

				retrivedInfo.owner = result2[1].firstname .. ' ' .. result2[1].lastname

				retrivedInfo.vehicle = json.decode(result[1].vehicle)

				cb(retrivedInfo)

			end)
		else
			cb(retrivedInfo)
		end
	end)
end)

ESX.RegisterServerCallback('rPolice:getArmoryWeapons', function(source, cb)
	TriggerEvent('esx_datastore:getSharedDataStore', 'society_police', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		cb(weapons)
	end)
end)

ESX.RegisterServerCallback('rPolice:removeArmoryWeapon', function(source, cb, weaponName)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 500)
	TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez retiré ~r~'..ESX.GetWeaponLabel(weaponName), 'CHAR_MP_FM_CONTACT', 8)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_police', function(store)
		local weapons = store.get('weapons') or {}

		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name = weaponName,
				count = 0
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('rPolice:addArmoryWeapon', function(source, cb, weaponName, removeWeapon)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(source)

	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
	end

	TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez déposé ~g~'..ESX.GetWeaponLabel(weaponName), 'CHAR_MP_FM_CONTACT', 8)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_police', function(store)
		local weapons = store.get('weapons') or {}
		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 1
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

RegisterNetEvent('gaming:plainte')
AddEventHandler('gaming:plainte', function(msg)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	sendToDiscordWithSpecialURL("Plaintes en ligne","**Plainte reçue de: __"..xPlayer.getName().."__**:\n\n"..msg, 16744192, Config.Webhook)
	TriggerClientEvent('esx:showNotification', source, "Votre plainte à bien été envoyé !")
end)

RegisterNetEvent('rPolice:prisedeservice')
AddEventHandler('rPolice:prisedeservice', function()
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	sendToDiscordWithSpecialURL("Prise de service",xPlayer.getName().." à prise son service", 16744192, Config.Webhook)
end)

RegisterNetEvent('rPolice:quitteleservice')
AddEventHandler('rPolice:quitteleservice', function()
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	sendToDiscordWithSpecialURL("Fin de service",xPlayer.getName().." à quitter son service", 16744192, Config.Webhook)
end)

function sendToDiscordWithSpecialURL(name,message,color,url)
    local DiscordWebHook = url
	local embeds = {
		{
			["title"]=message,
			["type"]="rich",
			["color"] =color,
			["footer"]=  {
			["text"]= "rPolice by Rayan Waize",
			},
		}
	}
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end