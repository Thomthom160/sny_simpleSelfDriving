client.functions.initialize()

RegisterCommand('openSelfDriveMenu', function()
    if cache.vehicle and client.functions.isVehicleAllowed(GetEntityModel(cache.vehicle)) then
        if lib.getOpenMenu() == 'selfDriveMenu' then
            lib.hideMenu(true)
        else
            lib.showMenu('selfDriveMenu')
        end
    else
        client.functions.showNotification('vehicle_not_allowed', 'error')
    end
end)

local speedIndex = 1
local speedValues = {
    {label = '50 Km/h', description = 'Vitesse de Ville', data = 50},
    {label = '90 Km/h', description = 'Vitesse de voie rapide', data = 90},
    {label = '120 Km/h', description = "Vitesse d'Autoroute", data = 120},
    {label = 'Max', description = 'Vitesse Maximale du Véhicule', data = 'max'}
}

local getSpeedByIndex = function(index)
    if speedValues[index].data == 'max' then
        return (GetVehicleEstimatedMaxSpeed(cache.vehicle) or 100) + 0.0
    end
    local speed = speedValues[index].data or 100.0
    return (speed + 0.0) / 3.6
end

local selfDriveThread = {
    flag = false,
    IsThreadActive = false,
    stop = function(self, shouldBreak)
        self.flag = false
        client.functions.stopSelfDriving(shouldBreak, false)
    end,
    start = function(self)
        if self.flag then return end
        CreateThread(function()
            self.flag = true
            local wpCheck = false
            while self.flag do
                Wait(100)
                local forceStop = false
                while not cache.vehicle and self.flag do Wait(100) end

                if not client.functions.isDriver(cache.vehicle) or IsEntityDead(cache.ped) then
                    forceStop = true
                end
                if client.isDriving then
                    if client.target then
                        --if not IsWaypointActive() then
                        --    forceStop = true
                        --    client.functions.showNotification('waypoint_not_active', 'error')
                        --    client.functions.playSound('error')
                        --end
                        local waypoint = GetFirstBlipInfoId(8)
                        local waypointCoords = GetBlipInfoIdCoord(waypoint)
                        if #(waypointCoords - client.target) >= 50 then
                            client.functions.startSelfDriving(getSpeedByIndex(speedIndex), waypointCoords, false)
                            client.functions.showNotification('destination_changed', 'success')
                        end
                        if #(GetEntityCoords(cache.ped) - client.target) < config.drivingDistanceStop then
                            self.flag = false
                            client.functions.stopSelfDriving(true, false)
                            client.functions.showNotification('destination_reached', 'success')
                            client.functions.playSound('destination_reached')
                        elseif forceStop then
                            self.flag = false
                            client.functions.stopSelfDriving(true, true)
                        end
                    end
                end
            end
        end)
    end
}

lib.onCache('vehicle', function(new, old)
    if not new or not client.functions.isVehicleAllowed(GetEntityModel(new)) then 
        if client.isDriving then
            selfDriveThread:stop()
            client.functions.showNotification('left_vehicle', 'error')
        end
    end
end)


lib.registerMenu({
    id = 'selfDriveMenu',
    title = 'Menu Conduite Automatique',
    options = {
        {
            label = 'Démarrer / Stopper la conduite automatique',
            icon = 'fa-solid fa-car-side',
            close = false
        }, {label = '--- Options de conduite ---', close = false},
        {
            label = 'Vitesse Maximale',
            values = speedValues,
            defaultIndex = speedIndex
        },{
            label = 'Dépassement des Véhicles',
            description = 'La voiture ferras Dépasseras toutes les voitures quelle croise',
            checked = config.drivingStyleFlags.SwerveAroundAllVehicles.enabled,
            close = false
        },{
            label = 'Vitesse Automatique',
            description = 'La voiture Changeras automatiquement de vitesse selon la limitation actuelle',
            checked = config.drivingStyleFlags.AdjustCruiseSpeedBasedOnRoadSpeed.enabled,
            close = false
        },{
            label = 'Chemin le plus court',
            description = 'La voiture prendra le chemin le plus court possible, même des chemins de terre',
            checked = config.drivingStyleFlags.UseShortCutLinks.enabled,
            close = false
        },{
            label = 'Eviter les autoroutes',
            description = 'La voiture ferras sont maximum pour ne pas prendre les autoroutes',
            checked = config.drivingStyleFlags.TryToAvoidHighways.enabled,
            close = false
        }, 
    },
    onCheck = function(selected, checked, args)
        if selected == 4 then
            
            config.drivingStyleFlags.SwerveAroundAllVehicles.enabled = not config.drivingStyleFlags.SwerveAroundAllVehicles.enabled
            client.functions.calculateDrivingStyle()
            if client.isDriving then
                client.functions.startSelfDriving(getSpeedByIndex(speedIndex), false, false)
            end
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Dépassement des Véhicles',
                description = 'La voiture ferras Dépasseras toutes les voitures quelle croise',
                checked = config.drivingStyleFlags.SwerveAroundAllVehicles.enabled,
                close = false
            }, selected)
        elseif selected == 5 then
            config.drivingStyleFlags.AdjustCruiseSpeedBasedOnRoadSpeed.enabled = not config.drivingStyleFlags.AdjustCruiseSpeedBasedOnRoadSpeed.enabled
            client.functions.calculateDrivingStyle()
            if client.isDriving then
                client.functions.startSelfDriving(getSpeedByIndex(speedIndex), false, false)
            end
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Vitesse Automatique',
                description = 'La voiture Changeras automatiquement de vitesse selon la limitation actuelle',
                checked = config.drivingStyleFlags.AdjustCruiseSpeedBasedOnRoadSpeed.enabled,
                close = false
            }, selected)
        elseif selected == 6 then
            config.drivingStyleFlags.UseShortCutLinks.enabled = not config.drivingStyleFlags.UseShortCutLinks.enabled
            client.functions.calculateDrivingStyle()
            if client.isDriving then
                client.functions.startSelfDriving(getSpeedByIndex(speedIndex), false, false)
            end
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Chemin le plus court',
                description = 'La voiture prendra le chemin le plus court possible, même des chemins de terre',
                checked = config.drivingStyleFlags.UseShortCutLinks.enabled,
                close = false
            }, selected)
        elseif selected == 7 then
            config.drivingStyleFlags.TryToAvoidHighways.enabled = not config.drivingStyleFlags.TryToAvoidHighways.enabled
            client.functions.calculateDrivingStyle()
            if client.isDriving then
                client.functions.startSelfDriving(getSpeedByIndex(speedIndex), false, false)
            end
            lib.setMenuOptions('selfDriveMenu', {
                label = 'Eviter les autoroutes',
                description = 'La voiture ferras sont maximum pour ne pas prendre les autoroutes',
                checked = config.drivingStyleFlags.TryToAvoidHighways.enabled,
                close = false
            }, selected)
        end
    end,
    onSelected = function(selected, secondary, args)
    end,
    onSideScroll = function(selected, scrollIndex, args)
        if selected ~= 3 then return end
        speedIndex = scrollIndex
        if client.isDriving then
            client.functions.startSelfDriving(getSpeedByIndex(speedIndex), false, false)
        end
        lib.setMenuOptions('selfDriveMenu', {
            label = 'Vitesse Maximale',
            values = speedValues,
            defaultIndex = speedIndex
        }, selected)
    end
}, function(selected, scrollIndex, args)
    if selected ~= 1 then return end
    if client.isDriving then
        selfDriveThread:stop(false)
    else
        if not IsWaypointActive() then
            client.functions.showNotification('waypoint_not_active', 'error')
            client.functions.playSound('error')
            return
        end
        selfDriveThread:start()
        local waypoint = GetFirstBlipInfoId(8)
        local waypointCoords = GetBlipInfoIdCoord(waypoint)
        client.functions.startSelfDriving(getSpeedByIndex(speedIndex), waypointCoords, true)
    end
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if cache.resource ~= resourceName then return end
    selfDriveThread:stop(false)
end)
