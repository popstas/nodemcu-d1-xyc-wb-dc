mqtt_client = mqtt.Client(mqtt_name, 30, mqtt_login, mqtt_password)

function mqtt_connect()
    print("mqtt connect to "..mqtt_host.."...")
    mqtt_client:connect(
        mqtt_host, 1883, 0, 1,
        function(client) print("mqtt connected") end,
        function(client, reason) print("mqtt connect failed, reason: "..reason) end
    )
    
    mqtt_client:on("offline", function(client) print ("mqtt offline") end)
end

function mqtt_publish(subtopic, value)
    --influx = "home "..subtopic.."="..value 
    --mqtt_client:publish(mqtt_topic.."/"..subtopic, influx, 0, 0)
    mqtt_client:publish(mqtt_topic.."/"..subtopic, value, 0, 0)
end
