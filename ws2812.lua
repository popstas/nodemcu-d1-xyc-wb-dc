ws2812.init()

local buffer = ws2812.newBuffer(1, 3)

buffer:fill(0, 0, 0)
ws2812.write(buffer)

buffer:fill(255, 0, 0)
