--[[
    All of the stuff required. I wonder if I can do
    something like:
    local ethernet, event = require("IPv2/ethernet"), require("event")
    I'll have to try :)
]]

local event = require("event")
local packet = require("IPv2/packet")
local cache = require("IPv2/cache")
local log = require("IPv2/log")
local modem = require("IPv2/modem")

--[[
    Our startup function.
    1) Looks for modems
    2) If found a modem, appropriately open it
]]

local status, err = pcall(modem.initialize)
if not status then
    log.log("EMERG", "Modem Initialization", err)
end

local status, err = pcall(cache.set, "modems", modem.getStats())
if not status then
    log.log("EMERG", "Modem cache set", err)
end

local status, err = pcall(log.save)
if not status then
    log.log("EMERG", "Log save", err)
end

while true do
    local _, destinationMAC, sourceMAC, VLAN, distance, payload = event.pull("modem_message")
    print("Got a message from [" .. sourceMAC .. "] on [" .. destinationMAC .. "] on VLAN [" .. VLAN .. "] data: " .. tostring(payload))
    local status, err = pcall(packet.ethernet.check, payload)
    if not status then
        log.log("EMERG", "Ethernet packet check", err)
    end
    modem.addRX(destinationMAC, packet.getSize(payload))
    print("Size of packet:" .. packet.getSize(payload))
    modems = modem.getStats()
    print("Current interface RX: ")
    for k, v in pairs(modems[destinationMAC]) do
        print(k .. " > " .. tostring(v))
    end
    local status, err = pcall(cache.set, "modems", modem.getStats())
    if not status then
        log.log("EMERG", "Modem cache set", err)
    end
end