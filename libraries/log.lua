local log = {}
local logFile = {}

local cache = require("IPv2/cache")
local os = require("os")
local component = require("component")
local term = require("term")
local computer = require("computer")
local math = require("math")

local gpu = component.gpu

-- LOCAL VARIABLES
local logLevel = 0

local logEvents = {
	[ "EMERG" ] = 0xa020f0, -- purple
	[ "ALERT" ] = 0xff0000, -- red
	[ "CRIT" ] = 0xff8c00, -- dark orange
	[ "ERR" ] = 0xffa500, -- orange
	[ "WARN" ] = 0xffd700, -- gold (yellow hurts my eyes)
	[ "NOTICE" ] = 0xffffe0, -- light yellow 
	[ "INFO" ] = 0x00ced1, -- dark turquoise (blue but readable. Regular blue you can't see)
    [ "DEBUG" ] = 0xadd8e6, -- light blue
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

local function tail(list)
	return { select(2, table.unpack(list)) }
end

function log.ramUsage()
	return ((computer.totalMemory() - computer.freeMemory()) / computer.totalMemory()) * 100
end

function log.checkRamUsage()
	if log.ramUsage() >= 85 then
		print("DUMPING LOG FILE")
		logFile = {}
	end
end

function log.getSeverity(arguments)
	return string.upper(arguments[1])
end

function log.buildMessage(arguments)
	local sev = log.getSeverity(arguments)
	local message = os.clock() .. " >> " .. "[" .. sev .. "] "
	for k, v in pairs(tail(arguments)) do
		message = message .. "[" .. v .. "] "
	end
	return message
end

function log.logMessage(message)
	table.insert(logFile, message)
end

function log.isInLogLevels(sev)
	for i=1, #logLevels[logLevel] do
		if logLevels[logLevel][i] == sev then
			return true
		end
	end
	return false
end

function log.printMessage(message)
	gpu.setForeground(logEvents[sev])
	print(message)
end

function checkAndPrintMessage(message, sev)
	if logEvents[sev] ~= nil then
		if log.isInLogLevels(sev) then
			log.printMessage(message)
		end
	end
end

function log.log(...)
	local arguments = {...}
	if #arguments < 2 then return false end
	
	local message = log.buildMessage(arguments)
	log.checkRamUsage()
	log.logMessage(message)
	log.checkAndPrintMessage(message, log.getSeverity(arguments))
end

function log.save()
    cache.set("log", logFile)
end

function log.get()
    return logFile
end

function log.init()
    logFile = cache.get("log")
end

function log.setLevel(level)
	logLevel = level
end

return log
