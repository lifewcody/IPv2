local fs = require("filesystem")
local libs = fs.list("/IPv2/libraries")
local autoruns = fs.list("/IPv2/autoruns")
local libraryToLoad = libs()
local autorunToLoad = autoruns()

if fs.exists("/lib/IPv2") == false then
    fs.makeDirectory("/lib/IPv2")
end

function SplitFilename(strFilename)
	return string.match(strFilename, "(.+)%..+")
end

while libraryToLoad ~= nil do
    print(libraryToLoad)
    local file = SplitFilename(libraryToLoad)
    local packageLoadedName = "IPv2/" .. file
    print("Package name: " .. packageLoadedName)
    package.loaded[packageLoadedName] = nil
    print(file .. " cleared")
    print("Copying " .. libraryToLoad)
    fs.copy("/IPv2/libraries/" .. libraryToLoad, "/lib/IPv2/" .. libraryToLoad)
    libraryToLoad = libs()
end

while autorunToLoad ~= nil do
    print(autorunToLoad)
    print("Copying " .. autorunToLoad)
    fs.copy("/IPv2/autoruns/boot/" .. autorunToLoad, "/boot/" .. autorunToLoad)
    autorunToLoad = autoruns()
end