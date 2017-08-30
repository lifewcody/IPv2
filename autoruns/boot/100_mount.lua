local filesystem = require("filesystem")
if filesystem.mount("f0ce470e-4356-4a7b-986a-a3a41de2a064", "/IPv2") then
    print("Succesfully mounted IPv2")
end