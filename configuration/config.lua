Config = {}

Config.CheckForUpdates = true --| Check for updates?
Config.InteractDistance = 2 -- Afstand voor ox_target interactie
Config.ShowDistance = 50 -- Afstand voor Text UI (optioneel, kan verwijderd worden als je geen Text UI wilt)
Config.PayAccount = 'bank' --| common: money or bank
Config.PayInterval = 7 --| Days

Config.SyncAllStorage = {
    enabled = false, --| If enabled the storage content is on every storage location the same
    buySeperate = false, --| Not recommended | If enabled you need to rent a location to get to your synced items
}

Config.Menu = {
    type = 'menu', --| context or menu
    position = 'top-left' --| top-left, top-right, bottom-left or bottom-right
}

Config.Stashes = {
    ['train_station'] = {
        coords = vec3(495.7195, -638.9720, 25.0627),
        label = 'Train Station Storage',
        pedModel = 'a_m_m_business_01', -- Ped-model voor deze stash
        pedScenario = 'WORLD_HUMAN_STAND_IMPATIENT', -- Scenario voor de ped
        types = {
            {
                name = 'Small storage',
                slots = 15,
                maxWeight = 10000,
                price = 1000 --| per interval
            },
            {
                name = 'Mid Storage',
                slots = 20,
                maxWeight = 20000,
                price = 5000 --| per interval
            },
            {
                name = 'Big Storage',
                slots = 25,
                maxWeight = 30000,
                price = 15000 --| per interval
            },
        }
    },
    ['south_side'] = {
        coords = vec3(-72.8946, -1820.9869, 26.9422),
        label = 'South Side Storage',
        pedModel = 'a_f_y_business_01', -- Ander ped-model (vrouwelijke zakenpersoon)
        pedScenario = 'WORLD_HUMAN_LEANING', -- Ander scenario (leunen tegen muur)
        types = {
            {
                name = 'Small storage',
                slots = 15,
                maxWeight = 10000,
                price = 1000 --| per interval
            },
            {
                name = 'Mid Storage',
                slots = 20,
                maxWeight = 20000,
                price = 5000 --| per interval
            },
            {
                name = 'Big Storage',
                slots = 25,
                maxWeight = 30000,
                price = 15000 --| per interval
            },
        }
    },
}
