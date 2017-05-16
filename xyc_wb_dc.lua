gpio.mode(xyc_pin, gpio.INPUT)

function detect_move(off_delay, scan_period, threshold)
    local buffer = {}
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

        --print("avg: " .. move_average)
        if move_average >= threshold then
            print("move_detected!")
        end
    end)
end

detect_move(10, 10, 0.5)
