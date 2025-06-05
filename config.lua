config = {}

config.language = 'fr' -- name of the language file to use

config.selfDrivingButton = 'U' -- button to toggle on self driving

config.drivingSpeed = false -- speed at which the car will travel
config.drivingDistanceStop = 35.0 -- distance from the target where self dricing will disable

-- Thanks to TomGrobbe for his work on https://vespura.com/fivem/drivingstyle/; I was able to understand the flags
config.drivingStyle = {
    [1] = true, -- Stop before vehicles
    [2] = true, -- Stop before peds
    [3] = false, -- Avoid vehicles
    [4] = true, -- Avoid empty vehicles
    [5] = true, -- Avoid peds
    [6] = true, -- Avoid objects
    [7] = false, -- Rentre dans les joueurs
    [8] = true, -- Stop at traffic lights
    [9] = true, -- Use blinkers
    [10] = false, -- Allow going wrong way (only does it if the correct lane is full, will try to reach the correct lane again a.s.a.p.)
    [11] = false, -- Drive in reverse gear
    [12] = false, -- Unknown
    [13] = false, -- Evite les zones restraintes
    [14] = false, -- Unknown
    [15] = false, -- Change la vitesse automatiquement
    [16] = false, -- Unknown
    [17] = false, -- Unknown
    [18] = false, -- Unknown
    [19] = true, -- Take shortest path (Removes most pathing limits, the driver even goes on dirt roads)
    [20] = true, -- Reckless (Previously named: Allow overtaking vehicles if possible)
    [21] = false, -- Unknown
    [22] = false, -- Unknown
    [23] = false, -- Ignore roads (Uses local pathing, only works within 200~ meters around the player)
    [24] = false, -- Unknown
    [25] = false, -- Ignore all pathing (Goes straight to destination)
    [26] = false, -- Unknown
    [27] = false, -- Unknown
    [28] = false, -- Unknown
    [29] = false, -- Unknown
    [30] = false, -- Avoid highways when possible (will use the highway if there is no other way to get to the destination)
    [31] = false -- Unknown
}

config.restrictVehicles = true -- will restrict usage of self driving onlu to allowed vehicles listed below

-- list of vehicles which self driving will work for (only works if restrictVehicles is set to true)
config.allowedVehicles = {
    [GetHashKey('cyclone')] = true,
    [GetHashKey('raiden')] = true,
    [GetHashKey('voltic')] = true,
    [GetHashKey('omnisegt')] = true,
    [GetHashKey('imorgon')] = true,
    [GetHashKey('tezeract')] = true
}

config.drivingStyleFlags = {
    StopForVehicles = {
        enabled = true, 
        value = 1
    },
    StopForPeds = {
        enabled = true, 
        value = 2
    },
    SwerveAroundAllVehicles = {
        enabled = false, 
        value = 4
    },
    SteerAroundStationaryVehicles = {
        enabled = true, 
        value = 8
    },
    SteerAroundPeds = {
        enabled = true, 
        value = 16
    },
    SteerAroundObjects = {
        enabled = true, 
        value = 32
    },
    DontSteerAroundPlayerPed = {
        enabled = false, 
        value = 64
    },
    StopAtTrafficLights = {
        enabled = true, 
        value = 128
    },
    GoOffRoadWhenAvoiding = {
        enabled = true, 
        value = 256
    },
    AllowGoingWrongWay = {
        enabled = true, 
        value = 512
    },
    Reverse = {
        enabled = false, 
        value = 1024
    },
    UseWanderFallbackInsteadOfStraightLine = {
        enabled = false, 
        value = 2048
    },
    AvoidRestrictedAreas = {
        enabled = true, 
        value = 4096
    },
    PreventBackgroundPathfinding = {
        enabled = false, 
        value = 8192
    },
    AdjustCruiseSpeedBasedOnRoadSpeed = {
        enabled = false, 
        value = 16384
    },
    UseShortCutLinks = {
        enabled = false, 
        value = 262144
    },
    ChangeLanesAroundObstructions = {
        enabled = true, 
        value = 524288
    },
    UseSwitchedOffNodes = {
        enabled = false, 
        value = 2097152
    },
    PreferNavmeshRoute = {
        enabled = false, 
        value = 4194304
    },
    PlaneTaxiMode = {
        enabled = false, 
        value = 8388608
    },
    ForceStraightLine = {
        enabled = false, 
        value = 16777216
    },
    UseStringPullingAtJunctions = {
        enabled = true, 
        value = 33554432
    },
    TryToAvoidHighways = {
        enabled = false, 
        value = 536870912
    },
    ForceJoinInRoadDirection = {
        enabled = false, 
        value = 1073741824
    },
    StopAtDestination = {
        enabled = true, 
        value = 2147483648
    }
}
