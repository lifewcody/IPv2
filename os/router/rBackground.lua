--[[
    Background process
]]

local event = require("event")
local packet = require("IPv2/packet")
local log = require("IPv2/log")
local modem = require("IPv2/modem")
local MAT = require("IPv2/MAT")

function modem_event_handler(event, destinationMAC, sourceMAC, VLAN, distance, payload)
    log.log("DEBUG", "Got a message from [" .. sourceMAC .. "] on [" .. destinationMAC .. "] on VLAN [" .. VLAN .. "] data: " .. tostring(payload))
    
    local status, err = pcall(modem.addRX, destinationMAC, packet.getSize(payload))
    if not status then
        log.log("EMERG", "Modem addRX", err)
    end

    local status, err = pcall(packet.ethernet.check, payload)
    if not status then
        log.log("EMERG", "Ethernet packet check", err)
    else
        if not err then
            return
        end
    end

    if not MAT.isInTable(sourceMAC) then
        log.log("DEBUG", sourceMAC, "Not in MAT table")
        MAT.add(sourceMAC, destinationMAC, VLAN)
        log.log("NOTICE", sourceMAC, "Added in MAT table")
    else
        log.log("DEBUG", sourceMAC, "Already in MAT table")
    end

    if _G.modems[destinationMAC] ~= nil then
        -- For the router
    end

    for k, v in pairs(_G.configuration["access-list"]) do
        if v["type"] == "ip" then
            -- TODO: IP Filtering
        elseif v["type"] == "mac" then
            if v["mode"] == "allow" then
                -- So far so good :)
            elseif v["mode"] == "deny" then
                if v["source"] == "any" then
                    log.log("INFO", "ACCESS-LIST", k, "DENY")
                    break
                elseif v["source"] == sourceMAC then
                    log.log("INFO", "ACCESS-LIST", k, "DENY")
                    break
                elseif v["destination"] == destinationMAC then
                    log.log("INFO", "ACCESS-LIST", k, "DENY")
                    break
                end
            end
        end
    end
end

if event.listen("modem_message", modem_event_handler) then
    log.log("DEBUG", "Modem event handler registration", "success")
else
    log.log("EMERG", "Modem event handler registration", "failure")
end