-- Packet Module
-- By lifewcody
-- Last Updated 2017.04.04.21.28

local moduleInformation = {
    name = "packet",
    version = "1.0.0"
}

-- LOCAL VARIABLES
local packet_info = {
    [1] = {
        ["format"] = {
            ["protocol"] = 2,
            ["ttl"] = 3,
            ["source"] = 4,
            ["destination"] = 5,
            ["data"] = 6,
        },
        ["protocols"] = {
            [1] = "TCP",
            [2] = "UDP",
        },
    },

    [2] = {
        ["format"] = {
            ["protocol"] = 2,
            ["ttl"] = 3,
            ["source"] = 4,
            ["destination"] = 5,
            ["data"] = 6,
        },
        ["protocols"] = {
            [1] = "ICMP",
            [6] = "TCP",
            [17] = "UDP",
        },
    },
}

-- LOCAL FUNCTIONS
local function getProtocolNum(version, protocol)
    if not protocol or protocol == "" then
        return 0
    end

    for k,v in pairs(packet_info[version].protocols) do
        if protocol == v then return k end
    end

    return 0
end

-- PACKET FUNCTIONS
-- Packet Reading Functions
function validatePacket(packet)
    return packet[1] ~= nil and packet_info[packet[1]] ~= nil
end

function getVersion(packet)
    return packet[1]
end

function getProtocol(packet)
    return packet_info[packet[1]].protocols[packet[packet_info[packet[1]].format.protocol]]
end

function getTTL(packet)
    return packet[packet_info[packet[1]].format.ttl]
end

function getSource(packet)
    return packet[packet_info[packet[1]].format.source]
end

function getDestination(packet)
    return packet[packet_info[packet[1]].format.destination]
end

function getData(packet)
    return packet[packet_info[packet[1]].format.data]
end

-- Packet Building Functions
function buildPacket(version, protocol, ttl, source, destination, data)
    if not packet_info[version] then return nil end
    return {
        [1] = version,
        [packet_info[version].format.protocol] = getProtocolNum(version, protocol),
        [packet_info[version].format.ttl] = ttl,
        [packet_info[version].format.source] = source,
        [packet_info[version].format.destination] = destination,
        [packet_info[version].format.data] = data,
    }
end

function setVersion(packet, version)
    packet[1] = version
    return packet
end

function setProtocol(packet, protocol)
    packet[packet_info[packet[1]].format.protocol] = getProtocolNum(packet[1], protocol)
    return packet
end

function setTTL(packet, ttl)
    packet[packet_info[packet[1]].format.ttl] = ttl
    return packet
end

function setSouce(packet, source)
    packet[packet_info[packet[1]].format.source] = source
    return packet
end

function setDestination(packet, destination)
    packet[packet_info[packet[1]].format.destination] = destination
    return packet
end

function setData(packet, data)
    packet[packet_info[packet[1]].format.data] = data
    return packet
end

-- UDP Functions
function getUDPSrcPort(data)
    return data[1]
end

function getUDPDstPort(data)
    return data[2]
end

function getUDPData(data)
    return data[3]
end

function buildUDP(srcPort, dstPort, data)
    return {
        [1] = srcPort,
        [2] = dstPort,
        [3] = data,
    }
end

function setUDPSrcPort(data, srcPort)
    data[1] = srcPort
    return data
end

function setUDPDstPort(data, dstPort)
    data[2] = dstPort
    return data
end

function setUDPData(data, udpData)
    data[3] = udpData
    return data
end

-- Packet Checking Functions

-- Check to make sure that the IP is numbers and not ham.sandwich
function IPCheck(ip)
    local pIP = {} -- Create blank table
    if ip == nil then return false end -- If it's nil, forget it
    for octect in string.gmatch(ip, "[^.]+") do -- Find the . and put each side of it into a table
        table.insert(pIP, octect) -- Insert here ;)
    end -- Lua would be angry if we didn't end
    if #pIP == 2 then -- Our IPs are 2 octets, not more, not less -- 2.
        if tonumber(pIP[1]) and tonumber(pIP[2]) then return true end -- If they're both numbers, cool
    end
    return false -- If they're not, welp.
end

function packetCheck(packet)
    if not #packet == 6 then return false end -- Must be a table 6 in length
    if not (tonumber(packet[1]) == 2) then return false end -- Check IPv2
    if tonumber(packet[2]) ~= 1 and packet[2] ~= 6 and packet[2] ~= 17 then return false end -- Check ICMP, UDP, or TCP
    if not (tonumber(packet[3]) >= 1) then return false end -- TTL is greater or equal to 1
    if not IPCheck(packet[4]) or not IPCheck(packet[5]) then return false end -- The packet (to/from) must be numbers
    if packet[6] == nil then return false end -- Must contain some data
    return true -- If our packet meets all the criteria
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    
end

function unload()
    
end