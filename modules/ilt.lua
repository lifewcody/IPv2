-- ILT Module
-- By Assossa
-- Last Updated 2017.04.04.20.41

local moduleInformation = {
	name = "ilt",
	version = "1.0.0",
	dependencies = {
		["cache"] = "cache.lua"
	}
}

-- ILT FUNCTIONS
function addToILT(IP, side)
	-- Add IP to ILT table
    _G.modules.ilt.ilt[IP] = side

	-- Save to cache
    cache.write("ilt", textutils.serialize(_G.modules.ilt.ilt))
end

function getILT(IP)
    return IP == nil and nil or _G.modules.ilt.ilt[IP]
end

function inILT(IP)
	return getILT(IP) ~= nil
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    -- Build our module object
    local moduleObject = {}

	-- Load the ILT table from cache or create a blank table
	local n = _G.modules.cache.readCache("ilt")
	moduleObject.ilt = n == nil and {} or textutils.unserialize(n)

    -- Write our module object to the global table
    _G.modules.ilt = moduleObject
end

function unload()
    
end