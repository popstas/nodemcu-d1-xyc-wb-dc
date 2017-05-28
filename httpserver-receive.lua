return function(conn, payload)
    if payload:find("Content%-Length:") or bBodyMissing then
        if fullPayload then fullPayload = fullPayload .. payload else fullPayload = payload end
        if (tonumber(string.match(fullPayload, "%d+", fullPayload:find("Content%-Length:")+16)) > #fullPayload:sub(fullPayload:find("\r\n\r\n", 1, true)+4, #fullPayload)) then
            bBodyMissing = true
            return false
        else
            payload = fullPayload
            fullPayload, bBodyMissing = nil
        end
    end
    collectgarbage()

    local req = dofile("httpserver-request.lc")(payload)

    print("method", req.method)
    print("request", req.request)

    return req
end
