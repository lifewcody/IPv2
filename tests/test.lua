local p = require("IPv2/ethernet")

p.packet.new("test")
p.packet.setDestination("aaa-bbb-ccc-ddd")
p.packet.setSource("eee-fff-ggg-hhh")
p.packet.setType(111)
p.packet.setPayload("My payload")

for k, v in pairs(p.packet.get()) do
    print(v)
end