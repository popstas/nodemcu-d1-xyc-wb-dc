mqtt_client = mqtt.Client('move-room')
if not mqtt_host then mqtt_host = "popstas-home" end

print("connect to "..mqtt_host)
mqtt_client:connect(
    mqtt_host, 1883, 0, 1,
    function(client) print("connected") end,
    function(client, reason) print("failed reason: "..reason) end
)

mqtt_client:on("offline", function(client) print ("mqtt offline") end)
