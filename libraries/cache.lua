local cache = {}

local io = require("io")
local serial = require("serialization")
local filesystem = require("filesystem")

function cache.set(name, data)
    local fs = io.open("/etc/IPv2/" .. name, "w")
    fs:write(serial.serialize(data))
    fs:close()
end

function cache.get(name)
    if filesystem.exists("/etc/IPv2/" .. name) == false then
        return serial.unserialize("{}")
    else
        local fs = io.open("/etc/IPv2/" .. name, "r")
        local file = fs:read()
        fs:close()
        if file == nil then
            print("File is nil")
            return serial.unserialize("{}")
        else
            return serial.unserialize(file)
        end
    end
end

function cache.initialize()
    if not filesystem.exists("/etc/IPv2") then
        filesystem.makeDirectory("/etc/IPv2")
    end
end

return cache