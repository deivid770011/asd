ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)






ESX.RegisterServerCallback('fFouille:getOtherPlayerData', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)

    if xPlayer then

        MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(result)

        local data = {
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            job2 = xPlayer.job2.label,
            grade2 = xPlayer.job2.grade_label,
            inventory = xPlayer.getInventory(),
            accounts = xPlayer.getAccounts(),
            weapons = xPlayer.getLoadout(),
            height = result[1].height,
            dob = result[1].dateofbirth
        } 
            if result[1].sex == 'h' then data.sex = 'Homme' else data.sex = 'Femme' end

            TriggerEvent('esx_license:getLicenses', target, function(licenses)
                data.licenses = licenses
        cb(data)
        end)
    end)
    end
end)


function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end


RegisterServerEvent('fellow:handcuff')
AddEventHandler('fellow:handcuff', function(target)
  TriggerClientEvent('fellow:handcuff', target)
end)

RegisterServerEvent('fellow:drag')
AddEventHandler('fellow:drag', function(target)
  local _source = source
  TriggerClientEvent('fellow:drag', target, _source)
end)

RegisterServerEvent('fellow:putInVehicle')
AddEventHandler('fellow:putInVehicle', function(target)
  TriggerClientEvent('fellow:putInVehicle', target)
end)

RegisterServerEvent('fellow:OutVehicle')
AddEventHandler('fellow:OutVehicle', function(target)
    TriggerClientEvent('fellow:OutVehicle', target)
end)

-------------------------------- Fouiller

RegisterNetEvent('fellow:confiscatePlayerItem')
AddEventHandler('fellow:confiscatePlayerItem', function(target, itemType, itemName, amount)
    local _source = source
    local sourceXPlayer = ESX.GetPlayerFromId(_source)
    local targetXPlayer = ESX.GetPlayerFromId(target)

    if itemType == 'item_standard' then
        local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		
			targetXPlayer.removeInventoryItem(itemName, amount)
			sourceXPlayer.addInventoryItem   (itemName, amount)
            TriggerClientEvent("esx:showNotification", source, "Vous avez confisqué ~b~"..amount..' '..sourceItem.label.."~s~.")
            TriggerClientEvent("esx:showNotification", target, "Quelqu'un vous a pris ~b~"..amount..' '..sourceItem.label.."~s~.")
        else
			--TriggerClientEvent("esx:showNotification", source, "~r~Quantidade inválida")
		end
        
    if itemType == 'item_account' then
        targetXPlayer.removeAccountMoney(itemName, amount)
        sourceXPlayer.addAccountMoney   (itemName, amount)
        
        TriggerClientEvent("esx:showNotification", source, "Vous avez confisqué ~b~"..amount.."€ ~s~argent non déclaré~s~.")
        TriggerClientEvent("esx:showNotification", target, "Quelqu'un vous a pris ~b~"..amount.."€ ~s~argent non déclaré~s~.")
        
    end
    
    if itemType == 'item_weapon' then
        if amount == nil then amount = 0 end
        targetXPlayer.removeWeapon(itemName, amount)
        sourceXPlayer.addWeapon   (itemName, amount)

        TriggerClientEvent("esx:showNotification", source, "Vous avez confisqué ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
        TriggerClientEvent("esx:showNotification", target, "Quelqu'un vous a confisqué ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
    end
end)

ESX.RegisterServerCallback('fellow:getOtherPlayerData', function(source, cb, target, notify)
    local xPlayer = ESX.GetPlayerFromId(target)

    TriggerClientEvent("esx:showNotification", target, "~r~~Quelqu'un vous fouille")

    if xPlayer then
        local data = {
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            inventory = xPlayer.getInventory(),
            accounts = xPlayer.getAccounts(),
            weapons = xPlayer.getLoadout()
        }

        cb(data)
    end
end)