#------
# Load configuration
#
include config

#------
# Hopefully no need to change anything below this line
#
OSC_DIR=/osc
INSTALL_OSC_SHARE=$(INSTALL_TOP_SHARE)$(OSC_DIR)

all clean:
	test -r src/osc.lua; test -r src/osc/client.lua; test -r src/osc/server.lua 

#------
# Files to install
#
TO_OSC_SHARE:= \
	client.lua \
	server.lua 

TO_TOP_SHARE:= \
	osc.lua 

#------
# Install according to recommendation
#
install: all
	cd src; mkdir -p $(INSTALL_TOP_SHARE)
	cd src; $(INSTALL_DATA) $(TO_TOP_SHARE) $(INSTALL_TOP_SHARE)
	cd src; mkdir -p $(INSTALL_OSC_SHARE)
	cd src$(OSC_DIR); $(INSTALL_DATA) $(TO_OSC_SHARE) $(INSTALL_OSC_SHARE)

#------
# End of makefile
#
