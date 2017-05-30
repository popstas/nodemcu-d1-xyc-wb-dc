######################################################################
# User configuration
######################################################################
# Path to nodemcu-uploader (https://github.com/kmpm/nodemcu-uploader)
NODEMCU-UPLOADER=nodemcu-tool
# Serial port
PORT=/dev/tty.wchusbserial14310
SPEED=115200

######################################################################
# End of user config
######################################################################
LUA_FILES := \
   init.lua \
   config_secrets.lua \
   start.lua \
   mqtt.lua \
   wifi.lua \
   ws2812.lua \
   ota.lua \
   http-request.lua \
   http-receive.lua \
   http-response.lua \
   xyc_wb_dc.lua \

# Print usage
usage:
	@echo "make upload FILE:=<file>  to upload a specific file (i.e make upload FILE:=init.lua)"
	@echo "make upload_all           to upload all"

# Upload one files only
upload:
	$(NODEMCU-UPLOADER) -b $(SPEED) -p $(PORT) upload $(FILE)

# Upload all
upload_all: $(LUA_FILES)
	$(NODEMCU-UPLOADER) -b $(SPEED) -p $(PORT) upload $(foreach f, $^, $(f))
