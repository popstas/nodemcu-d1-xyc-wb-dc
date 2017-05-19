function wifi_connect(ssid, password)
    print("connect to wifi "..ssid.."...")
    wifi.setmode(wifi.STATION)
    wifi.sta.config(ssid, password)
    wifi.sta.sethostname("nodemcu-d1")

    local ip = wifi.sta.getip()
    if not ip then ip = wifi.ap.getip() end
    if not ip then ip = "unknown IP" end
    print("nodemcu running at http://" .. ip)
end
