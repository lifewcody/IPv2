--[[
    rStart.
    Starts the shell and background process.
]]


-- Require what we need
local cache = require("IPv2/cache")
local modem = require("IPv2/modem")
local log = require("IPv2/log")
local configuration = require("IPv2/configuration")
local MAT = require("IPv2/MAT")
local os = require("os")


-- Initialize the cache with pcall, just in case
local status, err = pcall(cache.initialize)
if not status then
    log.log("EMERG", "Cache Initialization", err)
end

-- Initialize the modems
local status, err = pcall(modem.initialize)
if not status then
    log.log("EMERG", "Modem Initialization", err)
end

-- Open the modems
local status, err = pcall(modem.open)
if not status then
    log.log("EMERG", "Modem open", err)
end

-- Save the modems configuration files
local status, err = pcall(modem.save)
if not status then
    log.log("EMERG", "Modem save", err)
end

-- Save the log
local status, err = pcall(log.save)
if not status then
    log.log("EMERG", "Log save", err)
end

local status, err = pcall(configuration.initialize)
if not status then
    log.log("EMERG", "Configuration initialize", err)
end

local status, err = pcall(MAT.initialize)
if not status then
    log.log("EMERG", "MAT initialize", err)
end

-- Register the background process
os.execute("rBackground")

-- Set logging so we only see really important things
--log.setLevel(4) -- ERR, EMERG, CRIT, ALERT

os.execute("rShell")