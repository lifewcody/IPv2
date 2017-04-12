-- Modem Module
-- By lifewcody
-- Last Updated 2017.04.04.21.28

-- Module variables
local moduleInformation = {
	name = "modem",
	version = "1.0.0",
	dependencies = {
		["cache"] = "cache.lua",
		["log"] = "log.lua"
	}
}

local modems = {}

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

local function getSSID(side)
	return "CC" .. os.getComputerID() .. string.upper(string.sub(side,1,2))
end

local function getActiveSides()
	local as = {} -- Create empty table
	for s=1, #rs.getSides() do -- For each side on the computer: right, back, etc
		if peripheral.getType(rs.getSides()[s]) == "modem" then -- If something is on that side and it is a modem
			as[rs.getSides()[s]] = peripheral.call(rs.getSides()[s], "isWireless") -- Set the table key to the side and set it to if it's wireless (true = wireless, false = modem)
			modems[rs.getSides()[s]] = {
				[ "TX" ] = 0,
				[ "RX" ] = 0
			}
		end
	end
	return as -- Return the table, empty or has entries
end

local function saveConfig()
	_G.modules.cache.writeCache("modem", textutils.serialize(modems))
	_G.modules.cache.saveCache()
end

function openWiFi(side)
	print(modems.top.WiFi)
	if modems[side]["WiFi"] == nil then
		local WiFiInfo = { -- Create our Wifi table
			[ "channel" ] = math.random(150, 175), -- Open a random channel on 150 to 175
			[ "SSID" ] = getSSID(side), -- Generated the SSID. If it's on the top and CC ID is 1 then SSID is CC1TO
			[ "password" ] = generatePassword(6) -- Generates a 6 digit password
		}
		modems[side]["WiFi"] = WiFiInfo
	end
	_G.modules.log.log("INFO", "WiFi on " .. side)
	peripheral.call(side, "open", modems[side]["WiFi"]["channel"])
	for k, v in pairs(modems[side]["WiFi"]) do
		_G.modules.log.log("NOTICE", tostring(k) .. " >> " .. tostring(v))
	end
	return modems[side]["WiFi"]
end

local function open()
	-- Actually opens the modems and ports on the specific channel as before, etc.
end

-- MODEM FUNCTIONS
function openModems()
	print(modems.top.WiFi)
	for k, v in pairs(modems.top.WiFi) do
		print(k .. " > " .. tostring(v))
	end
	local activeSides = getActiveSides()
	for side, isWireless in pairs(activeSides) do
		if isWireless then
			openWiFi(side)
		else

		end
	end
	saveConfig()
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
	local n = _G.modules.cache.readCache("modem")
	if n == nil then
		_G.modules.cache.writeCache("modem", modems)
	else
		modems = textutils.unserialize(n)
	end
end

function unload()
    
end