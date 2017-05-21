## Files
- `init.lua` - index script, you can send any data to serial for abort startup
- `start.lua` - first script after `init.lua`
- `wifi.lua` - wifi init
- `xyc_wb_dc.lua` - microwave sendor module init
- `mqtt.lua` - mqtt init
- `user_modules.h` - file for `nodemcu-firmware`

## Setup
1. Rename `config_secrets.default.lua` to `config_secrets.lua`
2. Upload files:
```
make upload_all
```
