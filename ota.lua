local function ota_controller(conn, req, args)
    collectgarbage()
    local resp = ""
    --print("before request:", node.heap())
    local data = req.getRequestData()
    --print("after request:", node.heap())
   
    print("received OTA request:")
    local filename = data.filename
    local content = data.content
    local chunk_num = data.chunk

    print("filename:", filename)
    if chunk_num then
        print("chunk:", chunk_num)
    end

    --print("content:", content)
    if filename and content then
        local fmode = "w"
        if chunk_num and chunk_num ~= "1" then fmode = "a+" end

        local f = file.open(filename, fmode)
        if f then
            --print("content:", content)
            file.write(content)
            file.close()
            print("OK")
            dofile("httpserver-response.lc")(conn, 200, "OK")
            return
        else
            print("write file failed")
            dofile("httpserver-response.lc")(conn, 500, "ERROR")
            return
        end
    end
    dofile("httpserver-response.lc")(conn, 400, "Invalid arguments, use POST filename and content")
end


local function onReceive(conn, payload)
    local req = dofile('httpserver-receive.lc')(conn, payload)
    if req == false then
        return -- not all body received
    end

    if req.uri.file == "http/ota" then
        ota_controller(conn, req, req.uri.args)
    end

    if req.uri.file == "http/reset" and req.method == "POST" then
        dofile("httpserver-response.lc")(conn, 200, "restarting...")
        print("received restart signal over http")
        tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function()
            conn:close()
            node.restart()
        end)
    end

    req = nil
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
