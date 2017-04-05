-- ILT Module
-- By lifewcody
-- Last Updated 2017.04.04.20.41

local moduleInformation = {
	name = "ilt",
	version = "1.0.0",
	dependencies = {"cache"}
}

-- LOCAL FUNCTIONS
local function checkILT()
    if not _G.ilt then
		local n = _G["cache.lua"].readCache("ilt")
		if n then
			_G.ilt = textutils.unserialize(n)
		else
			_G.ilt = {}
		end
	end
end

-- ILT FUNCTIONS
function addToILT(IP, side)
    checkILT()
    _G.ilt[IP] = side
    cache.write("ilt", textutils.serialize(_G.ilt))
end

function inILT(IP)
    checkILT()
    return IP == nil and nil or _G.ilt[IP]
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    
end

function unload()
    
end