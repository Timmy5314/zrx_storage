CORE = exports.zrx_utility:GetUtility()

-- Thread om nabijheid te controleren en Text UI te tonen (optioneel)
CreateThread(function()
    local pedCoords

    while true do
        pedCoords = GetEntityCoords(cache.ped)

        for k, data in pairs(Config.Stashes) do
            if #(pedCoords - data.coords) <= Config.InteractDistance then
                CORE.Bridge.showTextUI(Strings.open_menu:format(data.label), {
                    icon = 'hand',
                })
            elseif #(pedCoords - data.coords) > Config.InteractDistance then
                local isOpen, text = CORE.Bridge.isTextUIOpen()

                if isOpen and text == Strings.open_menu:format(data.label) then
                    CORE.Bridge.hideTextUI()
                end
            end
        end

        Wait(0)
    end
end)

-- Blips toevoegen voor stash-locaties
CreateThread(function()
    for k, data in pairs(Config.Stashes) do
        CORE.Client.CreateBlip(data.coords, 473, 12, 0.5, data.label)
    end
end)

-- Peds spawnen en ox_target toevoegen
CreateThread(function()
    for k, data in pairs(Config.Stashes) do
        -- Ped spawnen
        local pedModel = GetHashKey(data.pedModel)
        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Wait(100)
        end

        local ped = CreatePed(4, pedModel, data.coords.x, data.coords.y, data.coords.z - 1.0, 0.0, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)

        -- Scenario laten uitvoeren
        TaskStartScenarioInPlace(ped, data.pedScenario, 0, true)

        -- ox_target toevoegen aan de ped
        exports.ox_target:addLocalEntity(ped, {
            {
                label = Strings.open_menu:format(data.label),
                icon = 'fa-solid fa-hand',
                onSelect = function()
                    local stashData = lib.callback.await('zrx_storage:server:getStashData', 1000, k)

                    if stashData then
                        ManageStash(k, stashData)
                    else
                        MenuStash(k)
                    end
                end
            }
        })

        SetModelAsNoLongerNeeded(pedModel)
    end
end)

-- ManageStash functie
ManageStash = function(configId, stashData)
    local MENU = {}

    MENU[#MENU+1] = {
        title = Strings.manage_open_title,
        description = Strings.manage_open_desc,
        icon = 'fa-solid fa-lock-open',
        arrow = true,
        onSelect = function()
            exports.ox_inventory:openInventory('stash', { id = stashData.stash_open, owner = stashData.owner })
        end
    }

    MENU[#MENU+1] = {
        description = '',
        disabled = true
    }

    MENU[#MENU+1] = {
        title = Strings.manage_cancel_title,
        description = Strings.manage_cancel_desc,
        icon = 'fa-solid fa-trash',
        arrow = true,
        onSelect = function()
            DeleteStash(configId, stashData)
        end
    }

    CORE.Client.CreateMenu({
        id = 'zrx_storage:ManageStash',
        title = Strings.storage,
    }, MENU, Config.Menu ~= 'menu', Config.Menu.position)
end

-- DeleteStash functie
DeleteStash = function(configId, stashData)
    local alert = CORE.Bridge.alertDialog(
        Strings.delete_alert_title,
        Strings.delete_alert_content:format(stashData.label),
        true,
        true
    )

    if alert == 'confirm' then
        TriggerServerEvent('zrx_storage:server:deleteStash', configId)
    else
        CORE.Bridge.notification(Strings.cancel_progress, Strings.storage, 'error')
    end
end

-- MenuStash functie
MenuStash = function(configId)
    local configData = Config.Stashes[configId]
    local MENU = {}

    MENU[#MENU+1] = {
        description = Strings.menu_info,
        readOnly = true,
    }

    MENU[#MENU+1] = {
        description = '',
        disabled = true
    }

    for stash, data in pairs(configData.types) do
        MENU[#MENU+1] = {
            title = Strings.menu_open_title:format(data.name),
            description = Strings.menu_open_desc,
            icon = 'fa-solid fa-house',
            arrow = true,
            metadata = {
                { label = Strings.menu_md_price_title:format(Config.PayInterval), value = Strings.menu_md_price_desc:format(lib.math.groupdigits(data.price, '.')) },
                { label = Strings.menu_md_slots_title, value = Strings.menu_md_slots_desc:format(data.slots) },
                { label = Strings.menu_md_weight_title, value = Strings.menu_md_weight_desc:format(lib.math.groupdigits(data.maxWeight, '.')) },
            },
            args = {
                slots = data.slots,
                maxWeight = data.maxWeight,
                price = data.price,
                label = data.name,
                stash_id = stash,
            },
            onSelect = function(args)
                BuyStash(args, configId)
            end
        }
    end

    CORE.Client.CreateMenu({
        id = 'zrx_storage:MenuStash',
        title = Strings.storage,
    }, MENU, Config.Menu ~= 'menu', Config.Menu.position)
end

-- BuyStash functie
BuyStash = function(data, configId)
    local alert = CORE.Bridge.alertDialog(
        Strings.buy_title,
        Strings.buy_desc:format(data.label, data.slots, lib.math.groupdigits(data.maxWeight, '.'), Config.PayInterval, lib.math.groupdigits(data.price, '.')),
        true,
        true
    )

    if alert == 'confirm' then
        TriggerServerEvent('zrx_storage:server:buyStash', data, configId)
    else
        CORE.Bridge.notification(Strings.buy_cancel, Strings.storage, 'error')
    end
end
