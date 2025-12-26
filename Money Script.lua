local var = {
    SCRIPT_NAME = 'Dr.Roh & MC MooHyun\'s Script',
    SCRIPT_VER = '1.1.0',

    delay_sec = {
        delay_1 = 500,
        delay_2 = 11500
    },

    loop_flag = {
        is_loop_running = false
    },

    limit_flag = {
        limit_selection = 10000000,
        got = 0,
    }
}

local stat_list = {
        {'Jobs', 'MONEY_EARN_JOBS'},
        {'Selling vehicle', 'MONEY_EARN_SELLING_VEH'},
        {'Betting', 'MONEY_EARN_BETTING'},
        {'Good sport', 'MONEY_EARN_GOOD_SPORT'},
        {'Picked up', 'MONEY_EARN_PICKED_UP'}
    }

local global_var = 1970025 --3725

local function notifyCustom(desc)
    notify.push(var.SCRIPT_NAME, desc)
end

local function stop(opt)
    if not opt.value then
        return true
    end

    if var.limit_flag.got >= var.limit_flag.limit_selection then
        notifyCustom('You withdraw the amount you limited.')
        opt.value = false
        return true
    end

    return false
end

local function set_global_i(i)
    script.globals(global_var).int32 = i
end

local function loop(opt)
    if stop(opt) then return end
    var.loop_flag.is_loop_running = true

    set_global_i(1)
    
    util.yield(var.delay_sec.delay_1)

    set_global_i(0)
    var.limit_flag.got = var.limit_flag.got + 500000

    if stop(opt) then return end

    util.yield(var.delay_sec.delay_2)
    
    if stop(opt) then return end
    set_global_i(2)

    util.yield(var.delay_sec.delay_1)

    set_global_i(0)
    var.limit_flag.got = var.limit_flag.got + 750000

    if stop(opt) then return end

    util.yield(var.delay_sec.delay_2)
end

local function clean_up()
    var.loop_flag.is_loop_running = false
end

local function Stat_Changer(stat, value)
    account.stats('MP' .. tostring(account.character()) .. '_' .. stat).int32 = account.stats('MP' .. tostring(account.character()) .. '_' .. stat).int32 + value
end

local root = menu.root()
local player_root = menu.player_root()

root:breaker('Money')

local Money_form = 0
root:number_int('Money Limit', menu.type.scroll)
    :tooltip('set your limit')
    :fmt('%i$', 0, 1000000000, 500000)
    :event(menu.event.click, function(opt)
        Money_form = opt.value
    end)

root:button('Apply Limit')
    :tooltip('apply your limit to loop')
    :event(menu.event.click, function(opt)
        var.limit_flag.limit_selection = Money_form
    end)


root:toggle('Money Loop', false)
    :tooltip('Give $2.5M per minute. apply your limit first. defalut limit is $100M')
    :event(menu.event.click, function(opt)
        if opt.value then
            while opt.value do
                loop(opt)
                util.yield()
            end
            clean_up()
        end
    end)

root:breaker('Statistic')

root:button('You\'ve earn $?')
    :tooltip('show how much you got')
    :event(menu.event.enter, function(opt)
        while true do 
            opt.name = 'You\'ve earn $' .. tostring(var.limit_flag.got)
            util.yield()
        end
    end)

root:combo_str('smart stat edit', stat_list, menu.type.press)
    :tooltip('Updates stats to match the exact amount earned.')
    :event(menu.event.click, function(opt)
        local selected = opt.list:at(opt.value)
        Stat_Changer(selected.value, var.limit_flag.got)
        notifyCustom('added $'..tostring(var.limit_flag.got)..' to '..tostring(selected.name))
        var.limit_flag.got = 0
    end)

root:breaker('Loop Status')

root:button('show it\'s running')
    :event(menu.event.enter, function(opt)
        while true do
            if var.loop_flag.is_loop_running then
                opt.name = 'Loop is running'
            else
                opt.name = 'Nothing is running'
            end
            util.yield()
        end

    end)

its test
