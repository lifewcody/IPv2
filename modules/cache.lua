local function check()
    if _G.icache == nil then
        _G.icache = {}
    end

    if _G.ucache == nil then
        _G.ucache = {}
    end
end

local function saveFile(path)
    ipath = _G.workingDir .. path

    if _G.icache[path] == nil then
        return
    end

    _G.ucache[path] = false
    local file = fs.open(ipath, "w")
    file.write(_G.icache[path])
    file.close()
end

local function loadCache(path)
    ipath = _G.workingDir .. path
    if fs.exists(ipath) then
        _G.ucache[path] = false
        local file = fs.open(ipath, "r")
        _G.icache[path] = fs.readAll()
        file.close()
    end
end

function setPath(path)
    _G.workingDir = path
end

function saveCache()
    for k,_ in pairs(_G.icache) do
        if type(k) == "string" and _G.ucache[k] == true then
            saveFile(k)
        end
    end
end

function writeCache(path, data)
    _G.icache[path] = data
    _G.ucache[path] = true
end

function readCache(path)
    check()

    if _G.icache[path] == nil then
        load(path)
    end

    return _G.icache[path]
end
