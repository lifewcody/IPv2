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

function openModems()

	_G["modems"] = _G["cache.lua"].readCache("modems")
	
	if _G["modems"] == nil then
		_G["modems"] = {}
	end
	
	for a=1, #rs.getSides() do
	
		if peripheral.getType(rs.getSides()[a]) == "modem" then
			if not _G["modems"][rs.getSides()[a]] then
				_G["modems"][rs.getSides()[a]] = {
					["TX"] = {},
					["RX"] = {}
				}
			end
			if peripheral.call(rs.getSides()[a], "isWireless") then
				if _G["modems"][rs.getSides()[a]]["WiFi"] == nil then
					_G["modems"][rs.getSides()[a]]["WiFi"] = {
						["channel"] = math.random(150, 175),
						["SSID"] = "CC" .. os.getComputerID() .. string.upper(string.sub(rs.getSides()[a],1,1)),
						["password"] = generatePassword(6)
					}
				end
				_G["log.lua"].log("NOTICE", string.upper(rs.getSides()[a]) .. " WiFi Information")
				for k,v in pairs(_G["modems"][rs.getSides()[a]]["WiFi"]) do
					_G["log.lua"].log("INFO", k .. " > " .. v)
				end
				_G["log.lua"].log("DEBUG", "---------------------------------------------------")
				peripheral.call(rs.getSides()[a], "open", _G["modems"][rs.getSides()[a]]["WiFi"]["channel"])
			else
				if _G["modems"][rs.getSides()[a]]["VLAN"] == nil then
					_G["modems"][rs.getSides()[a]]["VLAN"] = {
						1,
					}
				end
				for k,v in pairs(_G["modems"][rs.getSides()[a]]["VLAN"]) do
					peripheral.call(rs.getSides()[a], "open", _G["modems"][rs.getSides()[a]]["VLAN"][v])
					_G["log.lua"].log("DEBUG", "Opening VLAN " .. v .. " on " .. rs.getSides()[a])
				end
			end
		end
	
	end
	
	_G["cache.lua"].writeCache("modems", _G["modems"])
	
end

function modemLoop()



end