--[[
cache.load(path) - Loads a file into the cache
cache.saveFile(path) - Saves a specific file from the cache to the drive
cache.save() - Saves all cached files to the drive
cache.refresh() - Replaces cached files with version on drive, ignores cached files not on drive
cache.write(path, data) - Writes data to path in cache, overwrites existing data
cache.append(path, data) - Appends data to path in cache, includes existing data
cache.read(path) - Returns data in path. If file not in cache, but on drive, then it is loaded into the cache and returned. Returns nil if file is not on cache or drive
--]]

function load(path)
    if fs.exists(path) then
        _G.ucache[path] = false
        local file = fs.open(path, "r")
        _G.icache[path] = fs.readAll()
        file.close()
    end
end

function saveFile(path)
    if _G.icache[path] == nil then
        return
    end

    _G.ucache[path] = false
    local file = fs.open(path, "w")
    file.write(_G.icache[path])
    file.close()
end

function save()
    for k,_ in pairs(_G.icache) do
        if type(k) == "string" and _G.ucache[k] == true then
            saveFile(k)
        end
    end
end

function refresh()
    if _G.icache == nil then
        _G.icache = {}
    end

    if _G.ucache == nil then
        _G.ucache = {}
    end

    for _,v in pairs(_G.icache) do
        if type(v) == "string" then
            load(v)
        end
    end
end

function write(path, data)
    _G.icache[path] = data
    _G.ucache[path] = true
end

function append(path, data)
    if _G.icache[path] ~= nil then
        _G.icache[path] = _G.icache[path] .. data
        _G.ucache[path] = true
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
