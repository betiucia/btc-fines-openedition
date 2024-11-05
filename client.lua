local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterNetEvent('btc-fines:client:createfine', function(infratorid, id, location)
    local playerPed = PlayerPedId()
    SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
    Wait(1000)
    Citizen.InvokeNative(0x524B54361229154F, PlayerPedId(), GetHashKey("world_human_write_notebook"), 9999999999, true,
        false, false, false)

    local menu = jo.menu.create('finesmenu', {
        title = Language.lang_3,
        subtitle = Language.lang_4,
        onEnter = function()
        end,
        onBack = function()
            jo.menu.show(false)
            TriggerEvent('btc-fines:client:endanimation')
        end,
        onExit = function()
        end,
    })

    menu:addItem({
        title = Language.lang_5,
        icon = 'plus',
        statistics = {
            { value = Language.lang_6 },
        },
        onClick = function()
            jo.menu.show(false)
            local input = lib.inputDialog(Language.lang_7, {
                { type = 'input',    label = Language.lang_12, description = Language.lang_13, required = true, min = 4,         max = 16 },
                { type = 'input',    label = Language.lang_14, description = Language.lang_15, required = true, min = 4,         max = 16 },
                { type = 'textarea', label = Language.lang_8,  description = Language.lang_9,  autosize = true, required = true, min = 1, max = 500 },
                { type = 'number',   label = Language.lang_10, description = Language.lang_11, icon = 'hashtag' } })

            if not input then
                jo.menu.show(true)
                return
            end
            if input then
                local name = input[1]
                local lastname = input[2]
                local description = input[3]
                local fine = tonumber(input[4])
                TriggerServerEvent('btc-fines:server:registerfine', infratorid, name, lastname, description, fine,
                    location)
                TriggerEvent('btc-fines:client:endanimation')
            end
        end
    })

    menu:addItem({
        title = Language.lang_16,
        icon = 'tick',
        statistics = {
            { value = Language.lang_17 },
        },
        onClick = function()
            jo.menu.show(false)
            TriggerServerEvent('btc-fines:server:getarchivesall')
        end,
    })


    -------------
    -- Send the menu to the NUI
    -------------
    menu:send()

    -------------
    -- Define the current menu
    -------------
    jo.menu.setCurrentMenu('finesmenu', false, true)

    -------------
    -- Show the menu
    -------------
    jo.menu.show(true, true, false)
end)

RegisterNetEvent('btc-fines:client:endanimation', function()
    local playerPed = PlayerPedId()
    FreezeEntityPosition(PlayerPedId(), false)
    Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
    ClearPedTasks(PlayerPedId())
end)


RegisterNetEvent('btc-mdt:client:archivesall', function(archives, location, jobtype)
    local menu = jo.menu.create('archivesmenuall', {
        title = Language.lang_3,
        subtitle = Language.lang_18,
        onEnter = function()
        end,
        onBack = function()
            jo.menu.setCurrentMenu('finesmenu')
        end,
        onExit = function()
        end,
    })
    if jobtype == 'leo' then
        for _, v in pairs(archives) do
            menu:addItem({
                title = v.Name .. ' ' .. v.LastName,
                priceRight = v.Fine,
                icon = 'buyclothes',
                statistics = {
                    { label = Language.lang_19, value = v.Date },
                    { label = Language.lang_21, value = v.Officer },
                    { label = Language.lang_22, value = v.Location },
                    { label = Language.lang_23, value = v.Description },
                },
                onClick = function()
                    if location == v.location then
                        local PlayerJob = RSGCore.Functions.GetPlayerData().job
                        if PlayerJob.isboss then
                            local alert = lib.alertDialog({
                                header = Language.lang_24,
                                content = Language.lang_25,
                                centered = true,
                                cancel = true
                            })

                            if alert == 'confirm' then
                                TriggerServerEvent('btc-fines:server:deletefine', v.FineId)
                                TriggerEvent('btc-fines:client:endanimation')
                                jo.menu.show(false)
                            end
                        else
                            jo.notif.rightError(Language.lang_26)
                        end
                        jo.notif.rightError(Language.lang_27)
                    end
                end,
            })
        end
    else
        for _, v in pairs(archives) do
            if location == v.Location then
                menu:addItem({
                    title = v.Name .. ' ' .. v.LastName,
                    priceRight = v.Fine,
                    icon = 'buyclothes',
                    statistics = {
                        { label = Language.lang_19, value = v.Date },
                        { label = Language.lang_21, value = v.Officer },
                        { label = Language.lang_22, value = v.Location },
                        { label = Language.lang_23, value = v.Description },
                    },
                    onClick = function()
                        local PlayerJob = RSGCore.Functions.GetPlayerData().job
                        if PlayerJob.isboss then
                            local alert = lib.alertDialog({
                                header = Language.lang_24,
                                content = Language.lang_25,
                                centered = true,
                                cancel = true
                            })

                            if alert == 'confirm' then
                                TriggerServerEvent('btc-fines:server:deletefine', v.FineId)
                                TriggerEvent('btc-fines:client:endanimation')
                                jo.menu.show(false)
                            end
                        else
                            jo.notif.rightError(Language.lang_26)
                        end
                    end,
                })
            end
        end
    end

    -------------
    -- Send the menu to the NUI
    -------------
    menu:send()

    -------------
    -- Define the current menu
    -------------
    jo.menu.setCurrentMenu('archivesmenuall', false, true)

    -------------
    -- Show the menu
    -------------
    jo.menu.show(true, true, false)
end)

RegisterNetEvent('btc-mdt:client:myfinesmenu', function(archives, citizenid)
    local menu = jo.menu.create('myfinesmenu', {
        title = Language.lang_3,
        subtitle = Language.lang_18,
        onEnter = function()
        end,
        onBack = function()
            jo.menu.show(false)
        end,
        onExit = function()
        end,
    })

    for _, v in pairs(archives) do
        if citizenid == v.InfratorId then
            menu:addItem({
                title = v.Name .. ' ' .. v.LastName,
                priceRight = v.Fine,
                icon = 'buyclothes',
                statistics = {
                    { label = Language.lang_19, value = v.Date },
                    { label = Language.lang_21, value = v.Officer },
                    { label = Language.lang_22, value = v.Location },
                    { label = Language.lang_23, value = v.Description },
                },
                onClick = function()
                    TriggerServerEvent('btc-fines:server:payfine', v.FineId, v.Fine, v.Location)
                    TriggerEvent('btc-fines:client:endanimation')
                    jo.menu.show(false)
                end,
            })
        end
    end

    -------------
    -- Send the menu to the NUI
    -------------
    menu:send()

    -------------
    -- Define the current menu
    -------------
    jo.menu.setCurrentMenu('myfinesmenu', false, true)

    -------------
    -- Show the menu
    -------------
    jo.menu.show(true, true, false)
end)
