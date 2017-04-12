# IPv2
InZernet Protocol Version 2 for ComputerCraft

Official Forum: http://www.computercraft.info/forums2/index.php?/topic/27268-ipv2-inzernet-protocol-version-2-beta-rfc/page__fromsearch__1

# Structure

	/blade/ - Blade web browser
		blade.lua - Blade web browser

	/core_router/ - Everything related to the core router goes here
		core_router.lua - Core router dev file
	
	/installer/ - Installer files
		installer.lua - The installer program
		programs.ccon - List of applications
	
	/modules/ - Modules for iOS
		cache.lua - Cache module
		example.lua - Template module, never gets loaded
		ilt.lua - InZernet Location Table module
		log.lua - Log module
		modem.lua - Modem module
		module_manager.lua - Module Manager
		packet.lua - Packet module
		update.lua - Update module
	
	/RFC/ - Request For Comments
		Anything in here is for a protocol, or how something should operate
	
	/switch/ - Switch files
		switch.lua - Switch dev file
	
	/test/ - Testing files go here
		cr.lua - Test functions for core_router [OUT OF DATE]
		modemTest.lua - Test the modem module [UP TO DATE]adasdasd
		tst - Sends valid packets, to see if they get routed correctly [UP TO DATE]
	
	/buildInfo - Used for the update-check

# Build Number
	<Year>.<Month>.<Date>.<24Hour>.<Minute>
	For any version purposes | Includes leading 0's and is in EST
	
# Wiki

The Wiki provides documentation on modules and anything else, check there for anything that isn't covered.
