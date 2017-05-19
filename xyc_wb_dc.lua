function round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces>0 then
    local mult = 10^numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function detect_move(off_delay, scan_period, threshold, on_callback, off_callback)
    print("scan_period:", scan_period)
    print("off_delay:", off_delay)
    print("threshold:", threshold)

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

        mqtt_publish("move", move)
        mqtt_client:publish(mqtt_topic.."/avg", round(move_average*100, 0), 0, 0)
        print("move: ", move, "avg: ", round(move_average*100, 0))
        --print("move_detected: ", move_detected)

        if move_average >= threshold then
            if not move_detected then
                move_on_callback()
            end

            move_detected = true

            tmr.alarm(1, off_delay * 1000, tmr.ALARM_SINGLE, function()
                move_detected = move_average >= threshold
                if not move_detected then
                    move_off_callback()
                end
            end)
        end

    end)
end

function move_on_callback()
    mqtt_client:publish(mqtt_topic.."/move_detect", 1, 0, 0)
    print("move detected!")
    http.get(xyc_on_url)
end

function move_off_callback()
    mqtt_client:publish(mqtt_topic.."/move_detect", 0, 0, 0)
    print("move ended")
    http.get(xyc_off_url)
end
