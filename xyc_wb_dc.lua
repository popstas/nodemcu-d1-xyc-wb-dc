local function move_on_callback()
    mqttClient:publish("move_detect", 1)
    print("move detected!")
    http.get(xyc_on_url)
end

local function move_off_callback()
    mqttClient:publish("move_detect", 0)
    print("move ended")
    http.get(xyc_off_url)
end

return function(xyc_pin, off_delay, scan_period, on_threshold, off_threshold, on_callback, off_callback)
    local buffer = {}
    local move_detected = false
    gpio.mode(xyc_pin, gpio.INPUT)
    tmr.alarm(0, 1000, tmr.ALARM_AUTO, function()
        local move = gpio.read(xyc_pin)
        table.insert(buffer, move)
        if #buffer > scan_period then
            table.remove(buffer, 1)
        end
    
        local sum = 0
        for i = 1, #buffer do
            sum = sum + buffer[i]
        end
        move_average = sum / scan_period
    
        mqttClient:publish("avg", move_average*100)
        --print("move: ", move, "avg: ", move_average*100)
    
        if move_average >= on_threshold then
            if not move_detected then
                move_on_callback()
            end
            move_detected = true
    
            tmr.alarm(1, off_delay * 1000, tmr.ALARM_SINGLE, function()
                move_detected = move_average <= off_threshold
                if not move_detected then
                    move_off_callback()
                end
            end)
        end
    end)
end
