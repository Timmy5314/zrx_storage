Strings = {
    storage = 'Storage System',
    no_money = 'You dont have enough money',

    cancel_progress = 'You have canceled the rental process',

    open_menu = '[E] - Open %s menu', --| arg1: Storage name
    open_storage = 'Opens the storage',

    manage_open_title = 'Open Storage',
    manage_open_desc = 'Click to open the storage',
    manage_cancel_title = 'Cancel Storage',
    manage_cancel_desc = 'Click to cancel the storage',

    delete_alert_title = 'Are you sure?',
    delete_alert_content = 'Do you really want to cancel `%s`?  \n  \n**IMPORTANT**  \nYour items will not be deleted. After canceling your storage, you can rent it again!', --| arg1: Storage name
    delete_success = 'You successfully deleted %s', --arg1: Storage name

    menu_info = '× Fees will be automatically deducted from your bank account every 7 days  \n× If you don’t have enough money in your bank account, your storage will be automatically canceled  \n× You can only have one storage per storage location  \n× Storages are NOT synced across different locations  \n× After cancellation, your items will remain stored in the storage',
    menu_open_title = '%s', --| arg1: Storage name
    menu_open_desc = 'Click to rent the storage',
    menu_md_price_title = 'Price per %s days', --| arg1: Days
    menu_md_price_desc = '%s €', --| arg1: Price
    menu_md_slots_title = 'Slots',
    menu_md_slots_desc = '%s', --| arg1: Slots
    menu_md_weight_title = 'Maximum Weight',
    menu_md_weight_desc = '%s kg', --| arg1: Weight

    buy_title = 'Are you sure?',
    buy_desc = 'Do you really want to rent %s?  \n  \nSlots: **%s**  \nMaximum Weight: **%s kg**  \nPrice per %s days: **%s €**', --| arg1: Storage name - arg2: Slots - arg3: Weight - arg4: Days - arg5: Price
    buy_cancel = 'You have canceled the storage rental',
    buy_success = 'You successfully bought %s', --arg1: Storage name

    automatic_success = 'You successfully paid the rent for %s', --arg1: Storage name
    automatic_cancel = 'Your %s got canceled due to no left money' --arg1: Storage name
}