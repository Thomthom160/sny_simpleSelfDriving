client.functions.initialize()

lib.onCache('vehicle', function(new, old)
    if not (config.restrictVehicles and
        client.functions.isVehicleAllowed(vehicleModel)) or
        (not config.restrictVehicles) then selfDriveThread:stop(new) end
end)

local selfDriveThread = {
    flag = false,
    stop = function(self, vehicle)
        self.flag = false
        client.functions.stopSelfDriving(cache.ped, true, false)
    end,
    start = function(self, vehicle)
        CreateThread(function()
            while self.flag do
                Wait(100)
                local forceStop = false
                local distanceInterval = 0
                client.isPlayerAlive = not IsEntityDead(cache.ped)
                if not client.isInVehicle and client.isPlayerAlive then
                    if DoesEntityExist(GetVehiclePedIsTryingToEnter(cache.ped)) and
                        not client.isEnteringVehicle then
                        client.isEnteringVehicle = true
                    elseif not DoesEntityExist(
                        GetVehiclePedIsTryingToEnter(cache.ped)) and
                        not IsPedInAnyVehicle(cache.ped, true) and
                        client.isEnteringVehicle then
                        client.isEnteringVehicle = false
                    elseif IsPedInAnyVehicle(cache.ped, false) then
                        client.currentVehicle =
                            GetVehiclePedIsIn(cache.ped, false)
                        client.isEnteringVehicle = false
                        client.isInVehicle = true
                    end
                elseif client.isInVehicle then
                    if client.isDriving then
                        if not client.functions.isDriver(client.currentVehicle) then
                            forceStop = true
                        end
                    end
                    if not IsPedInAnyVehicle(cache.ped, false) or
                        not client.isPlayerAlive then
                        forceStop = true
                        client.isInVehicle = false
                        client.currentVehicle = 0
                        if client.isDriving then
                            client.functions.showNotification('left_vehicle',
                                                              'error')
                        end
                    end
                end

                if client.isDriving then
                    if client.target then
                        if not IsWaypointActive() then
                            forceStop = true
                            client.functions.showNotification(
                                'waypoint_not_active', 'error')
                            client.functions.playSound('error')
                        end
                        if (#(playerCoords - client.target) <
                            config.drivingDistanceStop) then
                            client.functions.stopSelfDriving(cache.ped, true,
                                                             false)
                            client.functions.showNotification(
                                'destination_reached', 'success')
                            client.functions.playSound('destination_reached')
                        elseif forceStop then
                            client.functions.stopSelfDriving(cache.ped, false,
                                                             true)
                        end
                    end
                end
            end
        end)
    end
}

lib.registerMenu({
    id = 'selfDriveMenu',
    title = 'Menu Conduite Automatique',
    options = {
        {
            label = 'Démarrer la conduite automatique',
            icon = 'fa-solid fa-car-side',
            close = false
        }, {label = '--- Options de conduite ---'}, {
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
        if selected == 3 then
            config.drivingStyle[19] = not config.drivingStyle[19]
            client.functions.calculateDrivingStyle()
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Chemin le plus court',
                description = 'La voiture prendra le chemin le plus court possible, même des chemins de terre',
                checked = config.drivingStyle[19]
            }, selected)
        elseif selected == 4 then
            config.drivingStyle[30] = not config.drivingStyle[30]
            client.functions.calculateDrivingStyle()
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Eviter les autoroutes',
                description = 'La voiture ferras sont maximum pour ne pas prendre les autoroutes',
                checked = config.drivingStyle[30]
            }, selected)
        end
    end,
    onSelected = function(selected, secondary, args)
        if selected ~= 1 then end
        if client.isDriving then
            client.functions.stopSelfDriving(cache.ped, false, true)
            selfDriveThread:stop(cache.vehicle)
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Démarrer la conduite automatique',
                icon = 'fa-solid fa-car-side',
                close = false
            }, selected)
        else
            if not IsWaypointActive() then
                client.functions
                    .showNotification('waypoint_not_active', 'error')
                client.functions.playSound('error')
                return
            end
            selfDriveThread:start(cache.vehicle)
            local waypoint = GetFirstBlipInfoId(8)
            local waypointCoords = GetBlipInfoIdCoord(waypoint)
            client.functions.startSelfDriving(cache.ped, playerVehicle, waypointCoords, true)
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Arrêter la conduite automatique',
                icon = 'fa-solid fa-car-side',
                close = false
            }, selected)
        end
    end
}, cb)
