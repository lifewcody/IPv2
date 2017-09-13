local configuration = {
    [ "accessList" ] = {},
}

local cache = require("IPv2/cache")

_G.configuration = {
    ["access-list"] = {},
}

function configuration.accessList.add(type, mode, source, destination)
    if _G.configuration["access-list"] == nil then
        _G.configuration["access-list"] = {}
    end
    table.insert(_G.configuration["access-list"], {
        ["type"] = type,
        ["mode"] = mode,
        ["source"] = source,
        ["destination"] = destination,
    })
end

function configuration.accessList.remove(id)
    _G.configuration["access-list"][id] = nil
end

function configuration.save()
    cache.set("configuration", _G.configuration)
end

function configuration.initialize()
    _G.configuration = cache.get("configuration")
end

return configuration