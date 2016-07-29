function load(path)
    if fs.exists(path) then
        local file = fs.open(path, "r")
        _G.icache[path] = fs.readAll()
        file.close()
    end
end

function saveFile(path)
    if _G.icache[path] == nil then
        return
    end

    local file = fs.open(path, "w")
    file.write(_G.icache[path])
    file.close()
end

function save()
    for k,_ in pairs(_G.icache) do
        if type(k) == "string" then
            saveFile(k)
        end
    end
end

function refresh()
    if _G.icache == nil then
        _G.icache = {}
    end

    for _,v in pairs(_G.icache) do
        if type(v) == "string" then
            load(v)
        end
    end
end

function write(path, data)
    _G.icache[path] = data
end

function append(path, data)
    if _G.icache[path] ~= nil then
        _G.icache[path] = _G.icache[path] .. data
    else
        write(path, data)
    end
end

function read(path)
    if _G.icache[path] == nil then
        load(path)
    end

    return _G.icache[path]
end
