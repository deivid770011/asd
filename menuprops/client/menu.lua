ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

object = {}
OtherItems = {}local inventaire = false
local status = true
--------------------------------------------------------------------------------
function OpenProps()
    local PropsMenu = RageUI.CreateMenu("Menu Props", "Catégories :")
    local PropsMenuobject = RageUI.CreateSubMenu(PropsMenu, "Props", "Appuyer sur ~g~E~w~ pour poser les objet")
    local PropsMenuobjectlist = RageUI.CreateSubMenu(PropsMenu, "Suppression d'objets", "Suppression d'objets")
    RageUI.Visible(PropsMenu, not RageUI.Visible(PropsMenu))
    while PropsMenu do
        Citizen.Wait(0)
        RageUI.IsVisible(PropsMenu, true, true, true, function()

            RageUI.ButtonWithStyle("Police", "Appuyer sur [~g~E~w~] pour poser les objet", { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
            end, PropsMenuobject)

            RageUI.ButtonWithStyle("Mode suppression", "Supprimer des objets", { RightLabel = "XXX" }, true, function(Hovered, Active, Selected)
            end, PropsMenuobjectlist)
    end, function()
    end)


RageUI.IsVisible(PropsMenuobject, true, true, true, function()

            RageUI.ButtonWithStyle("Cone", nil, {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_roadcone02a")
                end
            end)
            RageUI.ButtonWithStyle("Barrière", nil, {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_barrier_work05")
                end
            end)
            
            RageUI.ButtonWithStyle("Gros carton", nil, {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("prop_boxpile_07d")
                end
            end)

            RageUI.ButtonWithStyle("Herse", nil, {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("p_ld_stinger_s")
                end
            end)

            RageUI.ButtonWithStyle("Cash", nil, {}, true, function(Hovered, Active, Selected)
                if Selected then
                    SpawnObj("hei_prop_cash_crate_half_full")
                end
            end)

        end, function()
        end)

    RageUI.IsVisible(PropsMenuobjectlist, true, true, true, function()
            for k,v in pairs(object) do
                if GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v))) == 0 then table.remove(object, k) end
                RageUI.ButtonWithStyle("Object: "..GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v))).." ["..v.."]", nil, {}, true, function(Hovered, Active, Selected)
                    if Active then
                        local entity = NetworkGetEntityFromNetworkId(v)
                        local ObjCoords = GetEntityCoords(entity)
                        DrawMarker(0, ObjCoords.x, ObjCoords.y, ObjCoords.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 170, 1, 0, 2, 1, nil, nil, 0)
                    end
                    if Selected then
                        RemoveObj(v, k)
                    end
                end)
            end
            
        end, function()
        end)
        if not RageUI.Visible(PropsMenu) and not RageUI.Visible(PropsMenuobject) and not RageUI.Visible(PropsMenuobjectlist) then
            PropsMenu = RMenu:DeleteType("PropsMenu", true)
        end
    end
end

RegisterCommand('props', function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
        OpenProps()
else
    ESX.ShowNotification("Vous n'êtes pas policier pour utiliser cette commande")
end
end, false)
