client = {}
client.language = {}
client.isDriving = false
client.target = nil
client.drivingStyle = 0

client.functions = {}

client.functions.loadLanguages = function()
	local language = LoadResourceFile(GetCurrentResourceName(), '/lang/'..config.language..'.json')
    if language then
        jsonLanguage = json.decode(language)
        client.language = jsonLanguage[1]
    end
end

client.functions.isVehicleAllowed = function(modelHash)
    return config.allowedVehicles[modelHash]
end

client.functions.calculateDrivingStyle = function()
    local value = 0
    for k, v in pairs(config.drivingStyleFlags) do
        if v.enabled then
            value = value | v.value
        end
    end
    client.drivingStyle = value
end

client.functions.isDriver = function(playerVehicle)
    local vehicleDriver = GetPedInVehicleSeat(playerVehicle, -1)
    if (vehicleDriver == 0) then
        client.functions.showNotification('no_driver', 'error')
        return false
    end
    return vehicleDriver == cache.ped
end

client.functions.playSound = function(soundName)
    SendNUIMessage({
        action = 'play_sound',
        type = soundName
    })
end

client.functions.showNotification = function(message, messageType)
    if client.language[message] then
        lib.notify({
            title = 'Self Drive Menu',
            description = client.language[message], 
            type = messageType
        })
    else
        local msg = ("%s : %s\n%s"):format(client.language['missing_translation'], message, messageType)
        print(msg)
        lib.notify({
            title = 'Self Drive Menu',
            description = msg, 
            type = 'error'
        })
        client.functions.playSound('error')
    end
end

client.functions.startSelfDriving = function(speed, waypointCoords, playSound)
    if DoesEntityExist(cache.ped) and DoesEntityExist(cache.vehicle) then
        if (not waypointCoords) and client.isDriving then
            TaskVehicleDriveToCoordLongrange(cache.ped, cache.vehicle, client.target.x, client.target.y, client.target.z, speed or 100.0, client.drivingStyle, config.drivingDistanceStop)
        else
            client.target = waypointCoords
            client.isDriving = true
            TaskVehicleDriveToCoordLongrange(cache.ped, cache.vehicle, client.target.x, client.target.y, client.target.z, speed or 100.0, client.drivingStyle, config.drivingDistanceStop)
        end
        if playSound then
            client.functions.showNotification('start_self_driving', 'success')
            client.functions.playSound('enable')
        end
    end
end

client.functions.stopSelfDriving = function(brake, playSound)
    if DoesEntityExist(cache.ped) then
        if IsPedInAnyVehicle(cache.ped, false) then
            ClearVehicleTasks(cache.vehicle)
            if brake then
                Wait(100)
                TaskVehiclePark(cache.ped, cache.vehicle, client.target.x, client.target.y, client.target.z, 0, 1, 30, true)
                ClearVehicleTasks(cache.vehicle)
                Wait(3000)
                CreateThread(function()
                    while not IsVehicleStopped(cache.vehicle) do
                        Wait(0)
                        SetVehicleBrake(cache.vehicle, true)
                        SetVehicleHandbrake(cache.vehicle, true)
                    end
                    SetVehicleBrake(cache.vehicle, false)
                    SetVehicleHandbrake(cache.vehicle, false)
                end)
            end
        end
        client.isDriving = false
        client.target = nil
        client.functions.showNotification('stop_self_driving', 'error')
        if playSound then
            client.functions.playSound('disable')
        end
    end
end

client.functions.initialize = function()
    client.functions.loadLanguages()
    client.functions.calculateDrivingStyle()
end