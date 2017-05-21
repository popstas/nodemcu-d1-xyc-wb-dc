-- Variables --
xyc_pin          = 3
xyc_scan_period  = 60
xyc_off_delay    = 30
xyc_on_threshold = 0.02
xyc_off_threshold = 0
xyc_on_url       = "http://ws2812-strip-1/ws2812.lua?r=100&g=68&b=34"
xyc_off_url      = "http://ws2812-strip-1/ws2812.lua?r=0&g=0&b=0"
mqtt_topic       = "home/room/move"
mqtt_name        = "move-room"
mqtt_host        = "home.popstas.ru"

dofile("config_secrets.lc")
dofile('mqtt.lc')
dofile('ota.lc')
dofile('wifi.lc')
dofile('ws2812.lc')
dofile('xyc_wb_dc.lc')

if node_started then node.restart() end -- restart when included after start

wifi_connect(wifi_ssid, wifi_password)
ws2812_init()

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("nodemcu running at http://" .. T.IP)
    mqtt_connect()
    mqtt_client:on("connect", function(client)
        print("mqtt connected")
        move_detected = false
        gpio.mode(xyc_pin, gpio.INPUT)
        detect_move(xyc_off_delay, xyc_scan_period, xyc_on_threshold, xyc_off_threshold, on_callback, off_callback)
    end)
    ota_init()
    print("free after start:", node.heap())
end)

node_started = true
