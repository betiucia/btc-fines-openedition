local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterCommand(Config.CreateFine, function(source, args)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    local location = Player.PlayerData.job.name
    local player, distance = RSGCore.Functions.GetClosestPlayer(_source)
    local Infrator = RSGCore.Functions.GetPlayer(tonumber(player))

    for k, v in pairs(Config.PLayerJobTypes) do
        if Player.PlayerData.job.type == v then
            if  player ~= -1 and distance < 1 then
            local infratorid = Infrator.PlayerData.citizenid
            TriggerClientEvent('btc-fines:client:createfine', _source, infratorid, tonumber(1), location)
            else
            jo.notif.rightError(_source, Language.lang_2)
            end
            return
        end
    end
end)

RegisterCommand(Config.SeeFine, function(source, args)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)

    for k, v in pairs(Config.PLayerJobTypes) do
        if Player.PlayerData.job.type == v then
            TriggerEvent('btc-fines:server:getarchivesall')
            return
        end
    end
end)


RegisterCommand(Config.CheckFine, function(source, args)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    local citizenid = Player.PlayerData.citizenid

    TriggerEvent('btc-fines:server:getmyfines', _source, citizenid)
end)

RegisterNetEvent('btc-fines:server:registerfine', function(infratorid, name, lastname, description, fine, location)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    local officername = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    local date = os.date('!%d-%m')
    local param = {
        citizenid = infratorid,
        firstname = name,
        lastname = lastname,
        officername = officername,
        description =
            description,
        fine = fine,
        location = location,
        date = date
    }

    exports.oxmysql:execute(
        "INSERT INTO btc_fines (`citizenid`,`firstname`,`lastname`, `officername`, `description`,`fine`, `location`, `date`) VALUES (@citizenid, @firstname, @lastname, @officername, @description, @fine, @location, @date)",
        param)
    jo.notif.rightSuccess(_source, Language.lang_20)
end)

RegisterNetEvent('btc-fines:server:getarchivesall', function()
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    local location = Player.PlayerData.job.name
    local jobtype = Player.PlayerData.job.type
    local archives = {}
    local _source = source
    local players = MySQL.query.await("SELECT * FROM btc_fines")
    if players[1] ~= nil then
        for _, value in pairs(players) do
            archives[#archives + 1] = {
                FineId = value.id,
                InfratorId = value.citizenid,
                Name = value.firstname,
                LastName = value.lastname,
                Description = value.description,
                Officer = value.officername,
                Fine = value.fine,
                Location = value.location,
                Date = value.date,
            }
        end
        table.sort(archives, function(a)
            return a
        end)
        TriggerClientEvent('btc-fines:client:archivesall', _source, archives, location, jobtype)
    end
end)

RegisterNetEvent('btc-fines:server:getmyfines', function(source, citizenid)
    local _source = source
    local archives = {}
    local players = MySQL.query.await("SELECT * FROM btc_fines")
    if players[1] ~= nil then
        for _, value in pairs(players) do
            archives[#archives + 1] = {
                FineId = value.id,
                InfratorId = value.citizenid,
                Name = value.firstname,
                LastName = value.lastname,
                Description = value.description,
                Officer = value.officername,
                Fine = value.fine,
                Location = value.location,
                Date = value.date,
            }
        end
        table.sort(archives, function(a)
            return a
        end)
        TriggerClientEvent('btc-fines:client:myfinesmenu', _source, archives, citizenid)
    end
end)


RegisterNetEvent('btc-fines:server:deletefine', function(fineid)
    local _source = source
    MySQL.update('DELETE FROM btc_fines WHERE id = ?', { fineid })
    jo.notif.rightSuccess(_source, Language.lang_28)
end)

RegisterNetEvent('btc-fines:server:payfine', function(fineid, fineprice, location)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    local money = Player.Functions.GetMoney('cash')
    local cost = tonumber(fineprice)

        if money > fineprice then
            Player.Functions.RemoveMoney('cash', cost)
            MySQL.update('DELETE FROM btc_fines WHERE id = ?', { fineid })
            exports['rsg-bossmenu']:AddMoney(location, cost)
            jo.notif.rightSuccess(_source, Language.lang_29)
        else
            jo.notif.rightError(_source, Language.lang_30)
        end
end)
