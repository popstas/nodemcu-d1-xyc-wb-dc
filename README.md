## Files
- `init.lua` - index script, you can send any data to serial for abort startup
- `start.lua` - first script after `init.lua`
- `wifi.lua` - wifi init
- `xyc_wb_dc.lua` - microwave sendor module init
- `mqtt.lua` - mqtt init
- `user_modules.h` - file for `nodemcu-firmware`
- `nodemcu-ota-uploader.py` - script for upload file over HTTP


## Setup Mosquitto

1. Install:
```
apt-get install mosquitto
```

2. Configure `/etc/mosquitto/conf.d/auth.conf`:
```
allow_anonymous false
password_file /etc/mosquitto/passwd
```

3. Add password file:
```
mosquitto_passwd -c /etc/mosquitto/passwd username
```



## Setup NodeMCU
1. Rename `config_secrets.default.lua` to `config_secrets.lua`
2. Upload files:
```
make upload_all
```



## OTA update
You can send POST request to `/ota` with `filename` and `content` data.
HTTP request processed with `http-request.lua` from [marcoskirsch/nodemcu-httpserver](https://github.com/marcoskirsch/nodemcu-httpserver).

### OTA client
Setup client with `npm install`. Or better use `nodemcu-ota-uploader.py`

## nodemcu-ota-uploader
You should define `host` via command line:
```
nodemcu-ota-uploader --host 192.168.1.2
```
or via config `.ota` in project root:
```
host=192.168.1.2
```

Upload:
```
nodemcu-ota-uploader file.lua
```

Restart:
```
nodemcu-ota-uploader restart
```


## Health
You can see basic info on `/health`
