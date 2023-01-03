ESX, QBCore = nil, nil
if Config.Framework == 'ESX' then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


    ESX.RegisterUsableItem("tuning_laptop",function(source)
        local _source = source
        TriggerClientEvent("t3_tunerchip:useLaptop",source)
    end)

    ESX.RegisterServerCallback("t3_tunerchip:CheckStats",function(source,cb,veh)
        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate=@plate',{['@plate'] = veh.plate},function(retData)
            if retData and retData[1] and retData[1].tunerdata and retData[1].tunerdata ~= '' then
                if Config.Debug then
                    print("Tuned")
                end
                cb(true,json.decode(retData[1].tunerdata))
            else
                if Config.Debug then
                    print("Not Tuned")
                end
                cb(false,false)
            end
        end)  
    end)

    RegisterNetEvent('t3_tunerchip:SetData')
    AddEventHandler('t3_tunerchip:SetData', function(data,veh)
        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate=@plate',{['@plate'] = veh.plate},function(retData)
            if retData and retData[1] then
                MySQL.Async.execute('UPDATE owned_vehicles SET tunerdata=@tunerdata WHERE plate=@plate',{['@tunerdata'] = json.encode(data),['@plate'] = veh.plate},function(data)
                end)
            end
        end)
    end)
    
    RegisterNetEvent('t3_tunerchip:UnSetData')
    AddEventHandler('t3_tunerchip:UnSetData', function(veh)
        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate=@plate',{['@plate'] = veh.plate},function(retData)
            if retData and retData[1] then
                MySQL.Async.execute('UPDATE owned_vehicles SET tunerdata=@tunerdata WHERE plate=@plate',{['@tunerdata'] = '',['@plate'] = veh.plate},function(data)
                end)
            end
        end)
    end)
elseif Config.Framework == 'QBCore' then
    QBCore = exports['qb-core']:GetCoreObject()

    QBCore.Functions.CreateUseableItem("tuning_laptop",function(source, item)
        local _source = source
        TriggerClientEvent("t3_tunerchip:useLaptop",source)
    end)

    QBCore.Functions.CreateCallback("t3_tunerchip:CheckStats",function(source,cb,veh)
        MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate=@plate',{['@plate'] = veh.plate},function(retData)
            if retData and retData[1] and retData[1].tunerdata and retData[1].tunerdata ~= '' then
                if Config.Debug then
                    print("Tuned")
                end
                cb(true,json.decode(retData[1].tunerdata))
            else
                if Config.Debug then
                    print("Not Tuned")
                end
                cb(false,false)
            end
        end)  
    end)

    RegisterNetEvent('t3_tunerchip:SetData')
    AddEventHandler('t3_tunerchip:SetData', function(data,veh)
        MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate=@plate',{['@plate'] = veh.plate},function(retData)
            if retData and retData[1] then
                MySQL.Async.execute('UPDATE player_vehicles SET tunerdata=@tunerdata WHERE plate=@plate',{['@tunerdata'] = json.encode(data),['@plate'] = veh.plate},function(data)
                end)
            end
        end)
    end)
    
    RegisterNetEvent('t3_tunerchip:UnSetData')
    AddEventHandler('t3_tunerchip:UnSetData', function(veh)
        MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate=@plate',{['@plate'] = veh.plate},function(retData)
            if retData and retData[1] then
                MySQL.Async.execute('UPDATE player_vehicles SET tunerdata=@tunerdata WHERE plate=@plate',{['@tunerdata'] = '',['@plate'] = veh.plate},function(data)
                end)
            end
        end)
    end)
end