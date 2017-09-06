local modem = {}

local component = require("component")
local cache = require("IPv2/cache")
local log = require("IPv2/log")
--[[
    Our modems. connectedModems is the function,
    whereas connectedModemToLoad is the iteration
    of the function
]]
local connectedModems = component.list("modem")
local connectedModemToLoad = connectedModems()

--[[
    Declare all of our variables, that are not
    a require
]]
local modems = {}
local emptyModem = {
    [ "RX" ] = 0,
    [ "TX" ] = 0,
    [ "VLAN" ] = {
        1,
    },
}

function modem.initialize()
    modems = cache.get("modems")
    while connectedModemToLoad ~= nil do
        if modems[connectedModemToLoad] == nil then
            log.log("INFO", "FOUND", "MODEM", connectedModemToLoad)
            modems[connectedModemToLoad] = emptyModem
        end
        connectedModemToLoad = connectedModems()
    end
    modem.open()
end

function modem.getStats()
    return modems
end

function modem.addRX(modemMAC, amountToAdd)
    if modems[modemMAC] ~= nil then
        local rx = tonumber(modems[modemMAC]["RX"])
        rx = rx + tonumber(amountToAdd)
        modems[modemMAC]["RX"] = rx
    else
        log.log("NOTICE", "modem.addRX", "Modem does not exist")
    end
end

function modem.open()
    for currentModem, modemProperties in pairs(modems) do
        log.log("INFO", "LOADING", "MODEM", currentModem)
        for _, VLAN in pairs(modemProperties["VLAN"]) do
            component.invoke(currentModem, "open", VLAN)
            log.log("INFO", "OPENING", "MODEM", VLAN)
        end
    end
end

return modem