-- ILT Module
-- By Assossa
-- Last Updated 2017.04.08.22.22

local moduleInformation = {
	name = "ilt",
	version = "1.0.1",
	dependencies = {
		["cache"] = "cache.lua"
	}
}

-- ILT FUNCTIONS
function addToILT(IP, side)
	_G.modules.ilt.ilt[IP] = side
	_G.modules.cache.writeCache("ilt", _G.modules.ilt.ilt)

	-- Why are we printing here?
	for k, v in pairs(_G.modules.ilt.ilt) do
		print(k .. " > " .. v)
	end
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
	-- Load the ILT table from cache or create a blank table
	local n = _G.modules.cache.readCache("ilt")
	if n == nil then
		n = {}
		_G.modules.cache.writeCache("ilt", textutils.serialize(n))
	end

	-- Make sure we have a table for the module
	if _G.modules.ilt = nil then _G.modules.ilt = {} end

	-- Add the ilt table to a global variable
	_G.modules.ilt.ilt = n
end

function unload()
    _G.modules.cache.writeCache("ilt", textutils.serialize(_G.modules.ilt.ilt))
end