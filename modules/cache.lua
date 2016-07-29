function load(path)
    if fs.exists(path) then
        local file = fs.open(path, "r")
        _G.cache[path] = fs.readAll()
        file.close()
    end
end

function saveFile(path)
    if _G.cache[path] == nil then
        return
    end

    local file = fs.open(path, "w")
    file.write(_G.cache[path])
    file.close()
end

function save()
    for k,_ in pairs(_G.cache) do
        if type(k) == "string" then
            saveFile(k)
        end
    end
end

function refresh()
    if _G.cache == nil then
        _G.cache = {}
    end

    for _,v in pairs(_G.cache) do
        if type(v) == "string" then
            load(v)
        end
    end
end

function write(path, data)
    _G.cache[path] = data
end

function append(path, data)
    if _G.cache[path] ~= nil then
        _G.cache[path] = _G.cache[path] .. data
    else
        write(path, data)
    end
end

function read(path)
    if _G.cache[path] == nil then
        load(path)
    end

    return _G.cache[path]
end
