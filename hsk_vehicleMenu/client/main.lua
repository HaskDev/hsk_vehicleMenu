ESX     = exports['es_extended']:getSharedObject()
cache   = {
    policeStation = {x=441.47, y=-987.65, z=24.7, r=20}
}

--[Funciones y comandos]--
CreateThread(function()
    while ESX.GetPlayerData() == nil do
        Wait(100)
    end
    cache.playerData = ESX.GetPlayerData()
    while true do
        cache.playerPed     = PlayerPedId()
        cache.playerInVeh   = IsPedInAnyVehicle(cache.playerPed)
        Wait(1000)
    end
end)


RegisterCommand('extras', function()
    if not cache.playerPed then
        return
    end
    if cache.playerData and cache.playerData.job.name == 'police' then
        if #(GetEntityCoords(cache.playerPed) - vec3(cache.policeStation.x, cache.policeStation.y, cache.policeStation.z)) < cache.policeStation.r then
            if cache.playerInVeh then
                openVehicleMenu()
            end
        else
            ESX.ShowNotification("Tienes que estar a un radio de 20m del punto para poder modificar los extras del vehículo.")
        end
    else
        ESX.ShowNotification("No eres policia.")
    end
end)


function openVehicleMenu()
    local elems = {}
    
    table.insert(elems, {label = "Calcomanias", menu = 'livery'})
    table.insert(elems, {label = "Extras", menu = 'extra'})

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {
        title = "Opciones del vehículo",
        elements = elems,
        align = 'right'
    }, function(data, menu)
        if data.current.menu == 'livery' then
            openLiveryMenu(playerVehicle)
        end
        if data.current.menu == 'extra' then
            openExtraMenu(playerVehicle)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function openLiveryMenu()
    local playerVehicle = GetVehiclePedIsIn(cache.playerPed)
    local vehicleLiveries = GetVehicleLiveryCount(playerVehicle)
    local elems = {}

    for i = 1, vehicleLiveries do
        table.insert(elems, {label = "Calcomania #"..i, liveryId = i-1})
    end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'livery_menu', {
        title = "Calcomanias del vehículo",
        elements = elems,
        align = 'right'
    }, function(data, menu)
        SetVehicleLivery(playerVehicle, data.current.liveryId)
    end, function(data, menu)
        if cache.playerInVeh then
            openVehicleMenu()
        else
            menu.close()
        end
    end)
end

function openExtraMenu()
    local playerVehicle = GetVehiclePedIsIn(cache.playerPed)
    local vehicleExtras = {}
    
    for i = 0, 15 do
        if DoesExtraExist(playerVehicle, i) then
            local isExtraAlreadyInVeh = IsVehicleExtraTurnedOn(playerVehicle, i)
            table.insert(vehicleExtras, {label = "Extra #"..i.." - "..(isExtraAlreadyInVeh and "Aplicado" or "Sin aplicar"), extraId = i, extraInVeh = isExtraAlreadyInVeh})
        end
    end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'extra_menu', {
        title = "Extras del vehículo",
        elements = vehicleExtras,
        align = 'right'
    }, function(data, menu)
        if data.current.extraInVeh then
            SetVehicleExtra(playerVehicle, data.current.extraId, 1)
        else
            SetVehicleExtra(playerVehicle, data.current.extraId, 0)
        end
        return openExtraMenu()
    end, function(data, menu)
        if cache.playerInVeh then
            openVehicleMenu()
        else
            menu.close()
        end
    end)
end

--[Eventos]--
RegisterNetEvent('esx:playerLoaded', function(player)
    cache.playerData = player
end)

RegisterNetEvent('esx:setJob', function(job)
    cache.playerData = ESX.GetPlayerData()
    cache.playerData.job = job
end)