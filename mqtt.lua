m = mqtt.Client('move-room')

m:on("connect", function(client)
    print ("connected event")
    m:publish("/move", "1", 0, 0, function(client) print("sent") end)
end)
m:on("offline", function(client) print ("offline") end)

m:connect(mqtt_host, 1883, 0, function(client) print("connected") end, 
                                     function(client, reason) print("failed reason: "..reason) end)

