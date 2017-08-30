local fs = require("filesystem")
local libs = fs.list("/IPv2/libraries")
local libraryToLoad = libs()

if fs.exists("/lib/IPv2") == false then
    fs.makeDirectory("/lib/IPv2")
end

while libraryToLoad ~= nil do
    print(libraryToLoad)
    print("Copying " .. libraryToLoad)
    fs.copy("/IPv2/libraries/" .. libraryToLoad, "/lib/IPv2/" .. libraryToLoad)
    libraryToLoad = libs()
end