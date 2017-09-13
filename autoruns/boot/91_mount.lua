local filesystem = require("filesystem")
local component = require("component")

for address, componentType in component.list("filesystem") do

    if address == "3b850103-2ada-426a-ac65-45b6b8843dc9" then
        filesystem.mount("3b850103-2ada-426a-ac65-45b6b8843dc9", "/IPv2")
    end
    if address == "f0ce470e-4356-4a7b-986a-a3a41de2a064" then
        filesystem.mount("f0ce470e-4356-4a7b-986a-a3a41de2a064", "/IPv2")
    end
    if address == "fe852d87-d709-4a60-8f1d-0d80c90925d6" then
        filesystem.mount("fe852d87-d709-4a60-8f1d-0d80c90925d6", "/IPv2")
    end

end