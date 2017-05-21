local function ota_controller(conn, req, args)
    collectgarbage()
    print("before request:", node.heap())
    local data = req.getRequestData()
    print("after request:", node.heap())
   
    print("received OTA request:")
    local filename = data.filename
    local content = data.content
    print("filename:", filename)
    --print("content:", content)
    if filename and content then
        local f = file.open(filename, "w")
        if f then
            file.write(content)
            file.close()
            print("OK")
            conn:send("OK")
        else
            print("write file failed")
            conn:send("ERROR")
        end
    end
end

local function onReceive(conn, payload)
    if payload:find("Content%-Length:") or bBodyMissing then
        if fullPayload then fullPayload = fullPayload .. payload else fullPayload = payload end
        if (tonumber(string.match(fullPayload, "%d+", fullPayload:find("Content%-Length:")+16)) > #fullPayload:sub(fullPayload:find("\r\n\r\n", 1, true)+4, #fullPayload)) then
            bBodyMissing = true
            return
        else
            --print("HTTP packet assembled! size: "..#fullPayload)
            payload = fullPayload
            fullPayload, bBodyMissing = nil
        end
    end
    collectgarbage()

    local req = dofile("httpserver-request.lc")(payload)

    print("method", req.method)
    print("request", req.request)

    if req.uri.file == "http/ota" then ota_controller(conn, req, req.uri.args) end
    req = nil
    conn:close()
    collectgarbage()
end

local function onSent(conn, payload)
    conn:close()
end

return function()
    local s = net.createServer(net.TCP, 10)
    s:listen(80, function(conn)
        conn:on("receive", onReceive)
        conn:on("sent", onSent)
    end)
end
