local WiFi = {}

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

	for a=1, #rs.getSides() do
	
		if peripheral.getType(rs.getSides()[a]) == "modem" then
		
			if peripheral.call(rs.getSides()[a], "isWireless") then
				_G["log.lua"].log("DEBUG", "Found wirless modem on " .. rs.getSides()[a])
				_G["log.lua"].log("DEBUG", "Selecting random channel for WiFi")
				WiFi["channel"] = math.random(150, 175)
				_G["log.lua"].log("DEBUG", "Selected channel " .. WiFi["channel"])
				_G["log.lua"].log("DEBUG", "Opening WiFi")
				WiFi["SSID"] = "CC" .. os.getComputerID() .. string.upper(string.sub(rs.getSides()[a],1,1))
				WiFi["password"] = generatePassword(6)
				for k,v in pairs(WiFi) do
					print(k .. " > " .. v)
				end
			else
				_G["log.lua"].log("DEBUG", "Found wired modem on " .. rs.getSides()[a])
			end
		end
	
	end
	
end

function modemLoop()



end