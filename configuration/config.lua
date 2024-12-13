Config = {}

Config.CheckForUpdates = true --| Check for updates?
Config.InteractDistance = 2
Config.ShowDistance = 50
Config.InteractKey = 'E' --| Keymapping
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