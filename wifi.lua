wifi.setmode(wifi.STATION)
wifi.sta.config(wifi_ssid, wifi_password)
wifi.sta.sethostname("nodemcu-d1")

local ip = wifi.sta.getip()
if not ip then ip = wifi.ap.getip() end
if not ip then ip = "unknown IP" end
print("nodemcu running at http://" .. ip)
