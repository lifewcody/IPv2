if os.loadAPI("/disk/modules/module_manager.lua") == false then
	error("[EMERG] module_manager error loading")
end
_G["module_manager.lua"].init()
_G["module_manager.lua"].load()

_G.modules.modem.openModems()
