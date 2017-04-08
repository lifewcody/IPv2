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
    ilt = textutils.unserialize(_G.modules.cache.readCache("ilt"))

	ilt[IP] = side

	for k, v in pairs(ilt) do
		print(k .. " > " .. v)
	end

    _G.modules.cache.writeCache("ilt", ilt)
end

function getILT(IP)
	local ilt = _G.modules.cache.readCache("ilt")
    return IP == nil and nil or ilt[IP]
end

function inILT(IP)
	return getILT(IP) ~= nil
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
	-- Load the ILT table from cache or create a blank table
	local n = _G.modules.cache.readCache("ilt")
	if n == nil then
		_G.modules.cache.writeCache("ilt", textutils.unserialize("{}"))
	else
		moduleObject = textutils.unserialize(n)
	end
end

function unload()
    
end