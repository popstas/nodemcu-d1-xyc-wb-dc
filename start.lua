-- Variables --
xyc_pin          = 4
xyc_scan_period  = 60
xyc_off_delay    = 30
xyc_threshold    = 0.02
xyc_on_url       = "http://ws2812-strip-1/ws2812.lua?r=100&g=68&b=34"
xyc_off_url      = "http://ws2812-strip-1/ws2812.lua?r=0&g=0&b=0"
mqtt_host        = "popstas-server"
mqtt_topic       = "move"
wifi_ssid        = "ssid"

dofile('wifi.lua')
dofile('mqtt.lua')
dofile('ws2812.lua')
dofile('xyc_wb_dc.lua')

wifi_connect(wifi_ssid)
mqtt_connect()

mqtt_client:on("connect", function(client)
    move_detected = false
    gpio.mode(xyc_pin, gpio.INPUT)
    detect_move(xyc_off_delay, xyc_scan_period, xyc_threshold, on_callback, off_callback)
end)
