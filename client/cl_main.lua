client.functions.initialize()

lib.onCache('vehicle', function(new, old)
    if (config.restrictVehicles and client.functions.isVehicleAllowed(vehicleModel)) or (not config.restrictVehicles) then
        selfDriveThread:start(new)
    else
        selfDriveThread:stop(new)
    end
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
                    elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(cache.ped)) and
                        not IsPedInAnyVehicle(cache.ped, true) and
                        client.isEnteringVehicle then
                        client.isEnteringVehicle = false
                    elseif IsPedInAnyVehicle(cache.ped, false) then
                        client.currentVehicle = GetVehiclePedIsIn(cache.ped, false)
                        client.isEnteringVehicle = false
                        client.isInVehicle = true
                    end
                elseif client.isInVehicle then
                    if client.isDriving then
                        if not client.functions.isDriver(client.currentVehicle) then
                            forceStop = true
                        end
                    end
                    if not IsPedInAnyVehicle(cache.ped, false) or not client.isPlayerAlive then
                        forceStop = true
                        client.isInVehicle = false
                        client.currentVehicle = 0
                        if client.isDriving then
                            client.functions.showNotification('left_vehicle', 'error')
                        end
                    end
                end

                if client.isDriving then
                    if client.target then
                        if not IsWaypointActive() then
                            forceStop = true
                            client.functions.showNotification('waypoint_not_active', 'error')
                            client.functions.playSound('error')
                        end
                        if (#(playerCoords - client.target) < config.drivingDistanceStop) then
                            client.functions.stopSelfDriving(cache.ped, true, false)
                            client.functions.showNotification('destination_reached', 'success')
                            client.functions.playSound('destination_reached')
                        elseif forceStop then
                            client.functions.stopSelfDriving(cache.ped, false, true)
                        end
                    end
                end
            end
        end)
    end
}

RegisterCommand('toggleselfdriving', function()
    if DoesEntityExist(cache.ped) then
        if IsPedInAnyVehicle(cache.ped, false) then
            local playerVehicle = GetVehiclePedIsIn(cache.ped, false)
            local vehicleModel = GetEntityModel(playerVehicle)
            if client.functions.isDriver(playerVehicle) then
                if (config.restrictVehicles and
                    client.functions.isVehicleAllowed(vehicleModel)) or
                    (not config.restrictVehicles) then
                    if client.isDriving then
                        client.functions.stopSelfDriving(cache.ped, false, true)
                    else
                        if IsWaypointActive() then
                            local waypoint = GetFirstBlipInfoId(8)
                            local waypointCoords = GetBlipInfoIdCoord(waypoint)
                            client.functions.startSelfDriving(cache.ped, playerVehicle, waypointCoords, true)
                        else
                            client.functions.showNotification('waypoint_not_active', 'error')
                            client.functions.playSound('error')
                        end
                    end
                else
                    client.functions.showNotification('vehicle_not_allowed', 'error')
                    client.functions.playSound('error')
                end
            end
        end
    end
end, false)
--RegisterKeyMapping('toggleselfdriving', 'Toggle Self Driving', 'keyboard', config.selfDrivingButton)
