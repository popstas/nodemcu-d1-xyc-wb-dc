return function(conn, code, content)
    local codes = { [200] = "OK", [400] = "Bad Request", [404] = "Not Found", [500] = "Internal Server Error", }
    conn:send("HTTP/1.0 "..code.." "..codes[code].."\r\nServer: nodemcu-ota\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\n"..content)
    --
end
