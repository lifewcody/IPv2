local os = require("os")
local component = require("component")
local serial = require("serialization")

local network = component.getPrimary("modem")

local goodEthernetPacket = {
    "MAC-ADDRESS",
    "MAC-ADDRESS",
    17,
    {
        "An IP Packet",
        "Maybe :)",
    },
}

local badEthernetPacket = {
    451,
    677,
    17,
    {
        "An IP Packet",
        "Maybe :)",
    },
}

while true do
    network.broadcast(1, serial.serialize(badEthernetPacket))
    os.sleep(2)
end