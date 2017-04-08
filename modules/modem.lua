-- Modem Module
-- By lifewcody
-- Last Updated 2017.04.04.21.28

local moduleInformation = {
	name = "modem",
	version = "1.0.0",
	dependencies = {
		["cache"] = "cache.lua",
		["log"] = "log.lua"
	}
}

-- LOCAL FUNCTIONS
local function generatePassword(length)
	local code
	local validChars = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for i = 1, length do
		local idx = math.random(#validChars)
		if code == nil then
			code = validChars:sub(idx,idx)
		else
			code = code..validChars:sub(idx,idx)
		end
	end
	return code
end

-- MODEM FUNCTIONS
function openModems()
	if not _G.modems then
		local n = _G.modules.cache.readCache("modems")
		if n then
			_G.modems = n
		else
			_G.modems = {}
		end
	end
	
	for a=1, #rs.getSides() do
	
		if peripheral.getType(rs.getSides()[a]) == "modem" then
			if _G.modems[rs.getSides()[a]] == nil then
				_G.modems[rs.getSides()[a]] = {
					["TX"] = 0,
					["RX"] = 0,
				}
			end
			if peripheral.call(rs.getSides()[a], "isWireless") then
				if _G.modems[rs.getSides()[a]]["WiFi"] == nil then
					_G.modems[rs.getSides()[a]]["WiFi"] = {
						["channel"] = math.random(150, 175),
						["SSID"] = "CC" .. os.getComputerID() .. string.upper(string.sub(rs.getSides()[a],1,1)),
						["password"] = generatePassword(6)
					}
				end
				_G.modules.log.log("NOTICE", string.upper(rs.getSides()[a]) .. " WiFi Information")
				for k,v in pairs(_G.modems[rs.getSides()[a]]["WiFi"]) do
					_G.modules.log.log("INFO", k .. " > " .. v)
				end
				_G.modules.log.log("DEBUG", "---------------------------------------------------")
				peripheral.call(rs.getSides()[a], "open", _G.modems[rs.getSides()[a]]["WiFi"]["channel"])
			else
				if _G.modems[rs.getSides()[a]]["VLAN"] == nil then
					_G.modems[rs.getSides()[a]]["VLAN"] = {1}
				end
				for k,v in pairs(_G.modems[rs.getSides()[a]]["VLAN"]) do
					peripheral.call(rs.getSides()[a], "open", _G.modems[rs.getSides()[a]]["VLAN"][v])
					_G.modules.log.log("DEBUG", "Opening VLAN " .. v .. " on " .. rs.getSides()[a])
				end
			end
		end
	
	end
	
	_G.modules.cache.writeCache("modems", _G.modems)
	
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    
end

function unload()
    
end