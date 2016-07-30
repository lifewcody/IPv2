local logLevel = 0

local logEvents = {
	["EMERG"] = colors.red,
	["ALERT"] = colors.red,
	["CRIT"] = colors.orange,
	["ERR"] = colors.orange,
	["WARN"] = colors.yellow,
	["NOTICE"] = colors.yellow,
	["INFO"] = colors.lightBlue,
	["DEBUG"] = colors.blue,
}

local logLevels = {
	[0] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
		"WARN",
		"NOTICE",
		"INFO",
		"DEBUG",
	},
	[1] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
		"WARN",
		"NOTICE",
		"INFO",
	},
	[2] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
		"WARN",
		"NOTICE",
	},
	[3] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
		"WARN",
	},
	[4] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
	},
	[5] = {
		"EMERG",
		"ALERT",
		"CRIT",
	},
	[6] = {
		"EMERG",
		"ALERT",
	},
	[7] = {
		"EMERG",
	},
	[8] = {},

}

function log(...)
	testCache()
	
	local args = {...}
	
	if #args >= 1 then
		table.insert(_G["cache"]["log"], os.clock() .. " >> [" .. string.upper(args[1]) .. "] [" .. args[2] .. "]")
		if logEvents[string.upper(args[1])] ~= nil then
			local isInLogLevels = false
			for i=1, #logLevels[logLevel] do
				if logLevels[logLevel][i] == string.upper(args[1]) then
					isInLogLevels = true
				end
			end
			if isInLogLevels then
				term.setTextColor(logEvents[string.upper(args[1])])
				print(args[2])
			end
		end
		
	else
		return false
	end

end

function testCache()
	if _G["cache"]["log"] == nil then
		_G["cache"]["log"] = {}
	end
end

function setLogLevel(level)

	if tonumber(level) then
		logLevel = tonumber(level)
	else
		return false
	end

end