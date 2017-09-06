local packet = {
    ethernet = {},
}
local packets = {}
local currentPacket = nil
local version = "2017.08.30.10.44"
local serial = require("serialization")
local log = require("IPv2/log")

--[[
    Global Packet Functions
]]

function packet.netPacket(name)
    packets[name] = {}
    currentPacket = name
end

function packet.select(name)
    currentPacket = name
end

function packet.get()
    return packets[currentPacket]
end

function packet.getSize(packet)
    local size = 0
    if type(packet) == "string" then
        size = #packet
    elseif type(packet) == "table" then
        for k, v in pair(packet) do
            size = size + (#tostring(v))
        end
    end
    return size
end

--[[
    Ethernet Packet Functions
]]

function packet.ethernet.setDestination(mac)
    ethernetPackets[currentPacket][1] = mac
end

function packet.ethernet.setSource(mac)
    ethernetPackets[currentPacket][2] = mac
end

function packet.ethernet.setType(type)
    ethernetPackets[currentPacket][3] = type
end

function packet.ethernet.setPayload(paylod)
    ethernetPackets[currentPacket][4] = paylod
end

function packet.ethernet.check(packet)
    local packetID = math.random(0, 10000)
    packet = serial.unserialize(packet)
    if type(packet) == "table" then
        if #packet == 4 then
            if packet[1] ~= nil and packet[2] ~= nil then
                if tonumber(packet[3])  then
                    if packet[4] ~= nil then
                        return true
                    else
                        log.log("WARN", "No payload in packet")
                        return false
                    end
                else
                    log.log("WARN", "Packet type is invalid")
                    return false
                end
            else
                log.log("WARN", "Packet Source or Destination MAC is empty")
                return false
            end
        else
            log.log("WARN", "Packet length is not 4")
            return false
        end
    else
        log.log("WARN", "Ethernet packet is malformed")
        return false
    end
end

return packet