local pck = require("IPv2/packet")
pck.newPacket("test")
pck.setVersion(2)
pck.setProtocol(17)
pck.setTTL(255)
pck.setSource("ME")
pck.setDestination("YOU")
pck.setData("This is the data")

local myPacket = pck.get()
for k, v in pairs(myPacket) do
    print(k .. " > " .. v)
end

print("packet length: " .. pck.getLength(myPacket))