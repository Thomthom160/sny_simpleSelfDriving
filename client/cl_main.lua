client.functions.initialize()

lib.onCache('vehicle', function(new, old)
    if not new or not client.functions.isVehicleAllowed(GetEntityModel(new)) then 
        selfDriveThread:stop()
    end
end)

local selfDriveThread = {
    flag = false,
    IsThreadActive = false,
    stop = function(self)
        self.flag = false
        client.functions.stopSelfDriving(cache.ped, true, false)
    end,
    start = function(self, vehicle)
        if IsThreadActive then return end
        CreateThread(function()
            IsThreadActive = true
            while self.flag do
                Wait(100)
                local forceStop = false
                while not cache.vehicle and self.flag do Wait(100) end

                if not client.functions.isDriver(client.currentVehicle) or IsEntityDead(cache.ped) then
                    forceStop = true
                end
                if client.isDriving then
                    if client.target then
                        if not IsWaypointActive() then
                            forceStop = true
                            client.functions.showNotification( 'waypoint_not_active', 'error')
                            client.functions.playSound('error')
                        end
                        if (#(playerCoords - client.target) <
                            config.drivingDistanceStop) then
                            client.functions.stopSelfDriving(cache.ped, true, false)
                            client.functions.showNotification('destination_reached', 'success')
                            client.functions.playSound('destination_reached')
                        elseif forceStop then
                            client.functions.stopSelfDriving(cache.ped, true, true)
                        end
                    end
                end
            end
            IsThreadActive = false
        end)
    end
}


local speedIndex = 1
local speedValues = {
    {label = '50', description = 'Vitesse de Ville'},
    {label = '90', description = 'Vitesse de voie rapide'},
    {label = '120', description = "Vitesse d'Autoroute"},
    {label = 'Max', description = 'Vitesse Maximale du Véhicule'}
}

local getSpeedByIndex = function(index, vehicle)
    if speedValues[index].label == 'Max' then
        return (GetVehicleEstimatedMaxSpeed(vehicle) or 100) + 0.0
    end
    local speed = speedValues[index].label = tonumber(speedValues[index].label) or 100.0
    return (speed + 0.0) / 3.6
end


lib.registerMenu({
    id = 'selfDriveMenu',
    title = 'Menu Conduite Automatique',
    options = {
        {
            label = 'Démarrer la conduite automatique',
            icon = 'fa-solid fa-car-side',
            close = false
        }, {label = '--- Options de conduite ---', close = false},
        {
            label = 'Vitesse Maximale',
            values = speedValues,
            defaultIndex = speedIndex
        }, {
            label = 'Chemin le plus court',
            description = 'La voiture prendra le chemin le plus court possible, même des chemins de terre',
            checked = config.drivingStyle[19],
            close = false
        }, {
            label = 'Eviter les autoroutes',
            description = 'La voiture ferras sont maximum pour ne pas prendre les autoroutes',
            checked = config.drivingStyle[30],
            close = false
        }
    },
    onCheck = function(selected, checked, args)
        if selected == 4 then
            config.drivingStyle[19] = not config.drivingStyle[19]
            client.functions.calculateDrivingStyle()
            if client.isDriving then
                client.functions.startSelfDriving(cache.ped, playerVehicle, getSpeedByIndex(speedIndex, playerVehicle) waypointCoords, false)
            end
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Chemin le plus court',
                description = 'La voiture prendra le chemin le plus court possible, même des chemins de terre',
                checked = config.drivingStyle[19],
                close = false
            }, selected)
        elseif selected == 5 then
            config.drivingStyle[30] = not config.drivingStyle[30]
            client.functions.calculateDrivingStyle()
            if client.isDriving then
                client.functions.startSelfDriving(cache.ped, playerVehicle, getSpeedByIndex(speedIndex, playerVehicle) waypointCoords, false)
            end
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Eviter les autoroutes',
                description = 'La voiture ferras sont maximum pour ne pas prendre les autoroutes',
                checked = config.drivingStyle[30],
                close = false
            }, selected)
        end
    end,
    onSelected = function(selected, secondary, args)
        if selected ~= 1 then return end
        if client.isDriving then
            selfDriveThread:stop(cache.vehicle)
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Démarrer la conduite automatique',
                icon = 'fa-solid fa-car-side',
                close = false
            }, selected)
        else
            if not IsWaypointActive() then
                client.functions.showNotification('waypoint_not_active', 'error')
                client.functions.playSound('error')
                return
            end
            selfDriveThread:start(cache.vehicle)
            local waypoint = GetFirstBlipInfoId(8)
            local waypointCoords = GetBlipInfoIdCoord(waypoint)
            client.functions.startSelfDriving(cache.ped, playerVehicle, getSpeedByIndex(speedIndex, playerVehicle) waypointCoords, true)
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Arrêter la conduite automatique',
                icon = 'fa-solid fa-car-side',
                close = false
            }, selected)
        end
    end,
    onSideScroll = function(selected, scrollIndex, args)
        if selected ~= 3 then return end
        if client.isDriving then
            client.functions.startSelfDriving(cache.ped, playerVehicle, getSpeedByIndex(speedIndex, playerVehicle) waypointCoords, false)
        end
        lib.setMenuOptions('selfDriveMenu', {
            label = 'Vitesse Maximale',
            values = speedValues,
            defaultIndex = speedIndex
        }, selected)
    end
})

AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    selfDriveThread:stop(cache.vehicle)
end)
