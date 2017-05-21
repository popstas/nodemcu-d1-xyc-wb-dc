function ota_init()
    local s = net.createServer(net.TCP, 10)
    s:listen(80, function(conn)
        conn:on("receive", onReceive)
        conn:on("sent", onSent)
    end)
end

function onReceive(conn, payload)
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

    local req = dofile("httpserver-request.lua")(payload)

    print("method", req.method)
    print("request", req.request)

    if req.uri.file == "http/ota" then ota_controller(conn, req, req.uri.args) end
end

function onSent(conn, payload)
    conn:close()
end

function ota_controller(conn, req, args)
    local data = req.getRequestData()
    
    print("received OTA request:")
    local filename = data.filename
    local content = data.content
    print("filename:", filename)
    print("content:", content)
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
