local modem = {}

local component = require("component")
local cache = require("IPv2/cache")
local log = require("IPv2/log")
--[[
    Our modems. connectedModems is the function,
    whereas connectedModemToLoad is the iteration
    of the function
]]
local connectedModems
local connectedModemToLoad

--[[
    Declare all of our variables, that are not
    a require
]]
_G.modems = cache.get("modems")
local emptyModem = {
    [ "RX" ] = 0,
    [ "TX" ] = 0,
    [ "VLAN" ] = {
        1,
    },
}

function modem.initialize()
    connectedModems = component.list("modem")
    connectedModemToLoad = connectedModems()
    while connectedModemToLoad ~= nil do
        if _G.modems[connectedModemToLoad] == nil then
            log.log("INFO", "FOUND", "MODEM", connectedModemToLoad)
            _G.modems[connectedModemToLoad] = emptyModem
        end
        connectedModemToLoad = connectedModems()
    end
    -- Memory Savings
    connectedModemToLoad = nil
end

function modem.save()
    cache.set("modems", _G.modems)
end

function modem.addRX(modemMAC, amountToAdd)
    if _G.modems[modemMAC] ~= nil then
        _G.modems[modemMAC]["RX"] = _G.modems[modemMAC]["RX"] + amountToAdd
    else
        log.log("NOTICE", "modem.addRX", "Modem does not exist")
    end
end

function modem.open()
    for currentModem, modemProperties in pairs(_G.modems) do
        component.invoke(currentModem, "close")
        log.log("INFO", "LOADING", "MODEM", currentModem)
        -- Reset statistics
            modemProperties["RX"] = 0
            modemProperties["TX"] = 0
        for _, VLAN in pairs(modemProperties["VLAN"]) do
            component.invoke(currentModem, "open", VLAN)
            log.log("INFO", "OPENING", "MODEM", VLAN)
        end
    end
end

return modem