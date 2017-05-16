move_detected = false

gpio.mode(xyc_pin, gpio.INPUT)

function detect_move(off_delay, scan_period, threshold, on_callback, off_callback)
    local buffer = {}
    off_callback()
    tmr.alarm(0, 1000, tmr.ALARM_AUTO, function()
        local move = gpio.read(xyc_pin)
        table.insert(buffer, move)
        if #buffer > scan_period then
            table.remove(buffer, 1)
        end
        --print("move: " .. move)
        --print("buffer size: " .. #buffer)

        local sum = 0
        for i = 1, #buffer do
            sum = sum + buffer[i]
        end
        move_average = sum / scan_period

        print("avg: " .. move_average)
        --print("move_detected: ", move_detected)

        if move_average >= threshold then
            if not move_detected then
                on_callback()
            end

            move_detected = true

            tmr.alarm(1, off_delay * 1000, tmr.ALARM_SINGLE, function()
                move_detected = move_average >= threshold
                if not move_detected then
                    off_callback()
                end
            end)
        end

    end)
end

local on_callback = function()
    print("move detected!")
    http.get(xyc_on_url)
end
local off_callback = function()
    print("move ended")
    http.get(xyc_off_url)
end

detect_move(xyc_off_delay, xyc_scan_period, xyc_threshold, on_callback, off_callback)
