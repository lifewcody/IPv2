local cachePath = "/etc/IPv2/"
local cache = {}

local io = require("io")
local serial = require("serialization")
local filesystem = require("filesystem")

function cache.exists(name)
    return filesystem.exists(cachePath .. name)
end

function cache.openFile(name, mode)
    return io.open(cachePath .. name, mode)
end

function cache.getFile(name)
    local fs = cache.openFile(name, "r")
    local file = fs:read()
    fs:close()
    return file
end

function cache.set(name, data)
    local fs = cache.openFile(name, "w")
    fs:write(serial.serialize(data))
    fs:close()
end

function cache.get(name)
    if not cache.exists(name) then return {} end
    local file = cache.getFile(name)
    return serial.unserialize(file or "{}")
end

function cache.initialize()
    if not filesystem.exists("/etc/IPv2") then
        filesystem.makeDirectory("/etc/IPv2")
    end
end

return cache
