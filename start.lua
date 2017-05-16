-- Variables --
xyc_pin          = 4
xyc_scan_period  = 30
xyc_off_delay    = 30
xyc_threshold    = 0.1
xyc_on_url       = "http://ws2812-strip-1/ws2812.lua?r=100&g=68&b=34"
xyc_off_url      = "http://ws2812-strip-1/ws2812.lua?r=0&g=0&b=0"

dofile('wifi.lua')
dofile('ws2812.lua')
dofile('xyc_wb_dc.lua')
