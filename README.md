# IPv2
InZernet Protocol Version 2 for ComputerCraft

Official Forum: http://www.computercraft.info/forums2/index.php?/topic/27268-ipv2-inzernet-protocol-version-2-beta-rfc/page__fromsearch__1

# Structure

	/builds/ - Files ready to be tested go here

	/core_router/ - Everything related to the core router goes here

		cr - Core router file
		CoreRouter.lua - Core reouter test file

	/modules/ - Modules for iOS
	
		cache.lua - Cache module
		log.lua - Log module
		update.lua - Update module
	
	/test/ - Testing files go here

		testPacketSend - Wraps left modem and sends a packet every 3 seconds
		cr.lua - Test functions for core_router
	
	
	/buildInfo - Generates the build info for the pastebin updater

# Build Number

	<Year>.<Month>.<Date>.<24Hour>.<Minute>
(INCLUDES leading 0's and EST Time)
