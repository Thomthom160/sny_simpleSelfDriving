client = {}
client.language = {}
client.isDriving = false
client.currentVehicle = 0
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
    local binaryValue = ''
    for i = 31, 1, -1 do
        local checked = config.drivingStyle[i] and 1 or 0
        binaryValue = binaryValue..checked
    end
    client.drivingStyle = tonumber(binaryValue, 2)
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
        lib.notify(client.language[message], messageType)
    else
        lib.notify(("%s : %s\n%s"):format(client.language['missing_translation'], message, messageType), 'error')
        client.functions.playSound('error')
    end
end

client.functions.startSelfDriving = function(playerPed, playerVehicle, speed, waypointCoords, playSound)
    if DoesEntityExist(playerPed) and DoesEntityExist(playerVehicle) then
        client.currentVehicle = playerVehicle
        client.target = waypointCoords
        client.isDriving = true
        --local locked = GetVehicleDoorLockStatus(client.currentVehicle)
        TaskVehicleDriveToCoordLongrange(playerPed, client.currentVehicle, client.target.x, client.target.y, client.target.z, speed or 100.0, client.drivingStyle, config.drivingDistanceStop)
        --if locked ~= 2 then
        --    SetVehicleDoorsLocked(client.currentVehicle, 1)
        --end
        if playSound then
            client.functions.showNotification('start_self_driving', 'success')
            client.functions.playSound('enable')
        end
    end
end

client.functions.stopSelfDriving = function(playerPed, brake, playSound)
    if DoesEntityExist(playerPed) then
        if IsPedInAnyVehicle(playerPed, false) then
            ClearVehicleTasks(cache.vehicle)
            if brake then
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
            client.currentVehicle = 0
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