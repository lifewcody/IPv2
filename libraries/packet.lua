local packet = {}
local packets = {}
local currentPacket = nil

function packet.newPacket(name)
    packets[name] = {}
    currentPacket = name
end

function packet.selectPacket(name)
    currentPacket = name
end

function packet.setVersion(version)
    packets[currentPacket][0] = version
end

--[[
    function packet.setLength(length)
    length = length or length()
    packets[currentPacket[1]] = length(packets[currentPacket])
end
    ]]--

function packet.setProtocol(protocol)
    packets[currentPacket][1] = protocol
end

function packet.setTTL(TTL)
    packets[currentPacket][2] = TTL
end

function packet.setSource(sourceIP)
    packets[currentPacket][3] = sourceIP
end

function packet.setDestination(destination)
    packets[currentPacket][4] = destination
end

function packet.setData(data)
    packets[currentPacket][5] = data
end

function packet.fragment(packet)

end

function packet.get()
    return packets[currentPacket]
end