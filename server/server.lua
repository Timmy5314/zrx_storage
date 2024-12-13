CORE = exports.zrx_utility:GetUtility()
local STASHES = {}

CreateThread(function()
    if Config.CheckForUpdates then
        --CORE.Server.CheckVersion('zrx_storage')
    end

    MySQL.Sync.execute([[
        CREATE Table IF NOT EXISTS `zrx_storage` (
            `id` int(100) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(255) DEFAULT NULL,
            `stash_id` varchar(255) DEFAULT NULL,
            `data` longtext DEFAULT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `last_edited` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB;
    ]])

    local response = MySQL.query.await('SELECT * FROM `zrx_storage`', {})
    local stashData, stashId, stashId2

    for stash, data in pairs(response) do
        stashData = json.decode(data.data)

        if Config.SyncAllStorage.enabled then
            if Config.SyncAllStorage.buySeperate then
                stashId = ('%s_%s'):format(data.stash_id, data.identifier:match('^[^:]*'))
                stashId2 = ('zrx_storage_%s'):format(data.identifier:match('^[^:]*'))
            else
                stashId = ('zrx_storage_%s'):format(data.identifier:match('^[^:]*'))
                stashId2 = stashId
            end
        else
            stashId = ('%s_%s'):format(data.stash_id, data.identifier:match('^[^:]*'))
            stashId2 = stashId
        end

        STASHES[#STASHES+1] = {
            owner = data.identifier,
            slots = stashData.slots,
            maxWeight = stashData.maxWeight,
            label = stashData.label,
            price = stashData.price,
            stash_id = stashId,
            stash_open = stashId2
        }

        exports.ox_inventory:RegisterStash(stashId2, stashData.label, stashData.slots, stashData.maxWeight, data.identifier)
    end
end)

lib.callback.register('zrx_storage:server:getStashData', function(source, configId)
    local xPlayer = CORE.Bridge.getPlayerObject(source)
    local configData = Config.Stashes[configId]

    for k, data in pairs(STASHES) do
        if xPlayer.identifier == data.owner then
            if Config.SyncAllStorage.enabled then
                if Config.SyncAllStorage.buySeperate and data.stash_id:find(configId) then
                    return STASHES[k]
                elseif not Config.SyncAllStorage.buySeperate and data.stash_id:find('zrx_storage') then
                    return STASHES[k]
                end
            elseif data.stash_id:find(configId) then
                return STASHES[k]
            end
        end
    end

    return false
end)

RegisterNetEvent('zrx_storage:server:buyStash', function(data, configId)
    local xPlayer = CORE.Bridge.getPlayerObject(source)
    local xAccount = xPlayer.getAccount(Config.PayAccount)
    local configData = Config.Stashes[configId]
    local stashId, stashId2

    if xAccount.money >= data.price then
        xPlayer.removeAccountMoney(Config.PayAccount, data.price, 'Storage fee')
    else
        return CORE.Bridge.notification(xPlayer.source, Strings.no_money, Strings.storage, 'error')
    end

    if Config.SyncAllStorage.enabled then
        if Config.SyncAllStorage.buySeperate then
            stashId = ('%s_%s'):format(configId, xPlayer.identifier:match('^[^:]*'))
            stashId2 = ('zrx_storage_%s'):format(xPlayer.identifier:match('^[^:]*'))
        else
            stashId = ('zrx_storage_%s'):format(xPlayer.identifier:match('^[^:]*'))
            stashId2 = stashId
        end
    else
        stashId = ('%s_%s'):format(configId, xPlayer.identifier:match('^[^:]*'))
        stashId2 = stashId
    end

    STASHES[#STASHES+1] = {
        owner = xPlayer.identifier,
        slots = data.slots,
        maxWeight = data.maxWeight,
        label = data.label,
        price = data.price,
        stash_id = stashId,
        stash_open = stashId2
    }

    MySQL.insert.await('INSERT INTO `zrx_storage` (identifier, stash_id, data) VALUES (?, ?, ?)', {
        xPlayer.identifier, stashId, json.encode(data)
    })

    exports.ox_inventory:RegisterStash(stashId2, data.label, data.slots, data.maxWeight, xPlayer.identifier)

    CORE.Bridge.notification(xPlayer.source, Strings.buy_success:format(data.label), Strings.storage, 'success')
end)

RegisterNetEvent('zrx_storage:server:deleteStash', function(configId)
    local xPlayer = CORE.Bridge.getPlayerObject(source)
    local configData = Config.Stashes[configId]
    local stashId

    if Config.SyncAllStorage.enabled then
        stashId = ('zrx_storage_%s'):format(xPlayer.identifier:match('^[^:]*'))
    else
        stashId = ('%s_%s'):format(configId, xPlayer.identifier:match('^[^:]*'))
    end

    for k, data2 in pairs(STASHES) do
        if xPlayer.identifier == data2.owner then
            if Config.SyncAllStorage.enabled then
                if Config.SyncAllStorage.buySeperate and data2.stash_id:find(configId) then
                    STASHES[k] = nil
                elseif not Config.SyncAllStorage.buySeperate and data2.stash_id:find('zrx_storage') then
                    STASHES[k] = nil
                end
            elseif data2.stash_id:find(configId) then
                STASHES[k] = nil
            end
        end
    end

    MySQL.update.await('DELETE FROM `zrx_storage` WHERE (identifier, stash_id) = (?, ?)', { xPlayer.identifier, stashId })

    CORE.Bridge.notification(xPlayer.source, Strings.delete_success:format(configData.label), Strings.storage, 'error')
end)

lib.cron.new('*/15 * * * *', function()
    local selectQuery = ([[
        SELECT * FROM zrx_storage
        WHERE last_edited < NOW() - INTERVAL %s DAY
    ]]):format(Config.PayInterval)

    local rows = MySQL.query.await(selectQuery)
    local stashId

    if rows and #rows > 0 then
        for _, row in ipairs(rows) do
            local data2 = json.decode(row.data)
            local xPlayer = CORE.Bridge.getPlayerObjectByIdentifier(row.identifier)

            if xPlayer then
                local xAccount = xPlayer.getAccount(Config.PayAccount)

                if xAccount.money >= data2.price then
                    xPlayer.removeAccountMoney(Config.PayAccount, data2.price, 'Storage fee')

                    CORE.Bridge.notification(xPlayer.source, Strings.automatic_success:format(data2.label), Strings.storage, 'success')
                else
                    for k, data3 in pairs(STASHES) do
                        if xPlayer.identifier == data3.owner then
                            if Config.SyncAllStorage.enabled then
                                if Config.SyncAllStorage.buySeperate and data3.stash_id:find(row.stash_id) then
                                    STASHES[k] = nil
                                elseif not Config.SyncAllStorage.buySeperate and data3.stash_id:find('zrx_storage') then
                                    STASHES[k] = nil
                                end
                            elseif data3.stash_id:find(row.stash_id) then
                                STASHES[k] = nil
                            end
                        end
                    end

                    if Config.SyncAllStorage.enabled then
                        stashId = ('zrx_storage_%s'):format(xPlayer.identifier:match('^[^:]*'))
                    else
                        stashId = ('%s_%s'):format(row.stash_id, xPlayer.identifier:match('^[^:]*'))
                    end

                    MySQL.update.await('DELETE FROM `zrx_storage` WHERE (identifier, stash_id) = (?, ?)', { row.identifier, stashId })

                    CORE.Bridge.notification(xPlayer.source, Strings.automatic_cancel:format(data2.label), Strings.storage, 'error')
                end
            else
                local result = MySQL.query.await('SELECT `accounts` FROM `users` WHERE `identifier` = ?', { row.identifier })
                local data = result[1]
                local accounts = json.decode(data.accounts)

                if accounts.bank >= data2.price then
                    accounts.bank -= data2.price

                    MySQL.update.await('UPDATE users SET accounts = ? WHERE identifier = ?', {
                        json.encode(accounts), row.identifier
                    })
                else
                    for k, data3 in pairs(STASHES) do
                        if xPlayer.identifier == data3.owner then
                            if Config.SyncAllStorage.enabled then
                                if Config.SyncAllStorage.buySeperate and data3.stash_id:find(row.stash_id) then
                                    STASHES[k] = nil
                                elseif not Config.SyncAllStorage.buySeperate and data3.stash_id:find('zrx_storage') then
                                    STASHES[k] = nil
                                end
                            elseif data3.stash_id:find(row.stash_id) then
                                STASHES[k] = nil
                            end
                        end
                    end

                    if Config.SyncAllStorage.enabled then
                        stashId = ('zrx_storage_%s'):format(xPlayer.identifier:match('^[^:]*'))
                    else
                        stashId = ('%s_%s'):format(row.stash_id, xPlayer.identifier:match('^[^:]*'))
                    end

                    MySQL.update.await('DELETE FROM `zrx_storage` WHERE (identifier, stash_id) = (?, ?)', { row.identifier, stashId })
                end
            end
        end

        local updateQuery = ([[
            UPDATE zrx_storage
            SET last_edited = NOW()
            WHERE last_edited < NOW() - INTERVAL %s DAY
        ]]):format(Config.PayInterval)

        MySQL.update.await(updateQuery)
    end
end)