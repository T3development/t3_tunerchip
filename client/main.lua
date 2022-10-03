local menu = false
DefaultData = nil
ESX, QBCore = nil, nil

function getDefaultVehData(veh)
    if not DoesEntityExist(veh) then return nil end
    local vehStats = {
        turbo = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce"),
        speed = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel"),
        airFuel = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia"),
        brakeBias = GetVehicleHandlingFloat(veh ,"CHandlingData", "fBrakeBiasFront"),
        drive = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront"),
        brakeForce = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce")
    }
    if Config.Debug then
        print("Default:")
        print("turbo: "..vehStats.turbo)
        print("speed: "..vehStats.speed)
        print("airFuel: "..vehStats.airFuel)
        print("brakeBias: "..vehStats.brakeBias)
        print("drive: "..vehStats.drive)
        print("brakeForce: "..vehStats.brakeForce)
    end
    return vehStats
end
function getVehData(veh)
    if not DoesEntityExist(veh) then return nil end
    local vehStats = {}
    local responded = false
    if Config.Framework == 'ESX' then
        ESX.TriggerServerCallback('t3_tunerchip:CheckStats', function(doTune,stats)
            if doTune then
                vehStats = stats
            else
                vehStats.default = getDefaultVehData(veh)
                vehStats.values = {
                    turbo = 100,
                    airFuel = 100,
                    brakeForce = 100,
                    drive = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront"),
                    brakeBias = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront")
                }
            end
            responded = true
        end, ESX.Game.GetVehicleProperties(veh))
    elseif Config.Framework == 'QBCore' then
        QBCore.Functions.TriggerCallback('t3_tunerchip:CheckStats', function(doTune,stats)
            if doTune then
                vehStats = stats.values
            else
                vehStats.default = getDefaultVehData(veh)
                vehStats.values = {
                    turbo = 100,
                    airFuel = 100,
                    brakeForce = 100,
                    drive = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront"),
                    brakeBias = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront")
                }
            end
            responded = true
        end, QBCore.Functions.GetVehicleProperties(veh))
    end
    while not responded do Citizen.Wait(0); end
    if Config.Framework == 'ESX' then
        vehStats.isTurbo = ESX.Game.GetVehicleProperties(veh).modTurbo
    elseif Config.Framework == 'QBCore' then
        vehStats.isTurbo = QBCore.Functions.GetVehicleProperties(veh).modTurbo
    end
    return vehStats
end

function setVehData(veh,data,send)
    if not DoesEntityExist(veh) or not data then return nil end
    SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", (data.tune.turbo*1.0))
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", (data.tune.airFuel*1.0))
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", data.tune.brakeBias*1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", data.tune.drive*1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", (data.tune.brakeForce*1.0))
    if Config.Debug then
        print("Setting Data:")
        print("turbo: "..(data.tune.turbo*1.0))
        print("airFuel: "..(data.tune.airFuel*1.0))
        print("brakeBias: "..(data.tune.brakeBias*1.0))
        print("drive: "..(data.tune.drive*1.0))
        print("brakeForce: "..(data.tune.brakeForce*1.0))
    end
    if data.tune.trans < 1.0 then
        local acc = (1.0+(data.tune.trans/5.0))
        local spd = (1.0-(data.tune.trans/5.0))
        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", ((data.tune.turbo*1.0)*acc))
        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel", ((data.default.speed)*spd))
        if Config.Debug then
            print("Setting More Data:")
            print("turbo: "..((data.tune.turbo*1.0)*acc))
            print("speed: "..((data.default.speed)*spd))
        end
    elseif data.tune.trans > 1.0 then
        local acc = (1.0-((data.tune.trans-1.0)/5.0))
        local spd = (1.0+((data.tune.trans-1.0)/5.0))
        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", ((data.tune.turbo*1.0)*acc))
        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel", ((data.default.speed)*spd))
        if Config.Debug then
            print("turbo: "..((data.tune.turbo*1.0)*acc))
            print("speed: "..((data.default.speed)*spd))
        end
    end
    if send then
        if Config.Framework == 'ESX' then
            TriggerServerEvent('t3_tunerchip:SetData',data,ESX.Game.GetVehicleProperties(veh))
        elseif Config.Framework == 'QBCore' then
            TriggerServerEvent('t3_tunerchip:SetData',data,QBCore.Functions.GetVehicleProperties(veh))
        end
    end
end

Citizen.CreateThread(function()
    if Config.Framework == 'ESX' then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    elseif Config.Framework == 'QBCore' then
        while QBCore == nil do
            QBCore = exports['qb-core']:GetCoreObject()
            Citizen.Wait(0)
        end
    end
end)

function toggleMenu(b,send)
    menu = b
    SetNuiFocus(b,b)
    local vehData = getVehData(GetVehiclePedIsIn(PlayerPedId(),false))
    if send then SendNUIMessage(({type = "togglemenu", state = b, data = vehData})) end
end

RegisterNUICallback("togglemenu",function(data,cb)
    toggleMenu(data.state,false)
end)

RegisterNUICallback("save",function(data,cb)
    local veh = GetVehiclePedIsIn(PlayerPedId(),false)
    if not IsPedInAnyVehicle(PlayerPedId()) or GetPedInVehicleSeat(veh, -1)~=PlayerPedId() then return end
	if not data.default then
		data.default = DefaultData
	end
    data.tune = {
        turbo = (data.default.turbo * (data.values.turbo/100)),
        airFuel = (data.default.airFuel * (data.values.airFuel/100)),
        brakeForce = (data.default.brakeForce * (data.values.brakeForce/100)),
        trans = (data.values.trans/100),
        drive = data.values.drive,
        brakeBias = data.values.brakeBias
    }
    setVehData(veh,data,true)
end)

RegisterNetEvent("t3_tunerchip:useLaptop")
AddEventHandler("t3_tunerchip:useLaptop", function()
    if not menu then
        if Config.Framework == 'ESX' then
            exports["esx_progressbar"]:Progressbar("Connecting Laptop", 2500,{
                FreezePlayer = true, 
                animation ={
                    type = "anim",
                    dict = "anim@mp_player_intmenu@key_fob@", 
                    lib ="fob_click"
                },
                onFinish = function()
                    local ped = PlayerPedId()
                    toggleMenu(true,true)
                    while IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1)==ped do
                        Citizen.Wait(100)
                    end
                    toggleMenu(false,true)
            end})
        elseif Config.Framework == 'QBCore' then
            QBCore.Functions.Progressbar("connect_laptop", "Connecting Laptop", 2500, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer",
                flags = 16,
            }, {}, {}, function() -- Done
                StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                local ped = PlayerPedId()
                toggleMenu(true,true)
                while IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1)==ped do
                    Citizen.Wait(100)
                end
                toggleMenu(false,true)
            end, function() -- Cancel
                StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                QBCore.Functions.Notify("Cancelled before laptop connected", "error")
            end)
        end
    else
        return
    end
end)

RegisterNetEvent("t3_tunerchip:closeMenu")
AddEventHandler("t3_tunerchip:closeMenu",function()
    toggleMenu(false,true)
end)

local lastVeh = false
local lastData = false
local gotOut = false
Citizen.CreateThread(function(...)
    if Config.Framework == 'ESX' then
        while not ESX do Citizen.Wait(0); end
        while not ESX.IsPlayerLoaded() do Citizen.Wait(0); end
        while true do
            Citizen.Wait(30)
            if IsPedInAnyVehicle(PlayerPedId()) then
                local veh = GetVehiclePedIsIn(PlayerPedId(),false)
                if veh ~= lastVeh or gotOut then
                    if gotOut then gotOut = false; end
                    local responded = false
                    ESX.TriggerServerCallback('t3_tunerchip:CheckStats', function(doTune,stats)
                        if doTune then
                            setVehData(veh,stats)
                            lastStats = stats
                        else
                            DefaultData = getDefaultVehData(veh)
                        end
                        lastVeh = veh
                        responded = true
                    end, ESX.Game.GetVehicleProperties(veh))
                    while not responded do Citizen.Wait(0); end
                end
            else
                if not gotOut then
                    gotOut = true
                end
            end
        end
    elseif Config.Framework == 'QBCore' then
        while not QBCore do Citizen.Wait(0); end
        while true do
            Citizen.Wait(30)
            if IsPedInAnyVehicle(PlayerPedId()) then
                local veh = GetVehiclePedIsIn(PlayerPedId(),false)
                if veh ~= lastVeh or gotOut then
                    if gotOut then gotOut = false; end
                    local responded = false
                    QBCore.Functions.TriggerCallback('t3_tunerchip:CheckStats', function(doTune,stats)
                        if doTune then
                            setVehData(veh,stats)
                            lastStats = stats
                        else
                            DefaultData = getDefaultVehData(veh)
                        end
                        lastVeh = veh
                        responded = true
                    end, QBCore.Functions.GetVehicleProperties(veh))
                    while not responded do Citizen.Wait(0); end
                end
            else
                if not gotOut then
                    gotOut = true
                end
            end
        end
    end
end)

RegisterCommand("untune", function(source, args)
  TriggerServerEvent('t3_tunerchip:UnSetData', ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(),false)))
end)