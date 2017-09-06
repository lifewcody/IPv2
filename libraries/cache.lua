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
    if filesystem.exists("/etc/IPv2" .. name) == false then
        return serial.unserialize("{}")
    else
        local fs = io.open("/etc/IPv2/" .. name, "r")
        local file = fs.read()
        fs.close()
        if file == nil then
            return serial.unserialize("{}")
        else
            return serial.unserialize(file)
        end
    end
end

return cache