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
mqttClient = dofile('mqtt.lc')

if node_started then node.restart() end -- restart when included after start

dofile('wifi.lc')(wifi_ssid, wifi_password)
collectgarbage()
--dofile('ws2812.lc')()

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("http://" .. T.IP)
    mqttClient:connect()
    mqttClient.client:on("connect", function(client)
        print("mqtt connected")
        dofile('xyc_wb_dc.lc')(xyc_pin, xyc_off_delay, xyc_scan_period, xyc_on_threshold, xyc_off_threshold, on_callback, off_callback)
    end)
    dofile('ota.lc')()
    collectgarbage()
    print("free after wifi connected:", node.heap())
end)

node_started = true
