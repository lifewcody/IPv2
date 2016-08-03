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

-- Util Functions
local function getProtocolNum(version, protocol)
    if not protocol or protocol == "" then
        return 0
    end

    for k,v in pairs(packet_info[version].protocols) do
        if protocol == v then return k end
    end

    return 0
end

-- Packet Reading Functions
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
