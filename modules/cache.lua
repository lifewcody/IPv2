-- Cache Module
-- By Assossa
-- Last Updated 2017.04.04.20.20

local moduleInformation = {
    name = "cache",
    version = "1.0.0"
}

-- LOCAL FUNCTIONS
local function saveFile(path)
    -- Get the absolute path
    local ipath = _G.iOS.dir .. path

    -- If the file does not exist in the cache, then we don't need to save it
    if _G.modules.cache.icache[path] == nil then return end

    -- Save the file to the disk
    local file = fs.open(ipath, "w")
    file.write(_G.modules.cache.icache[path])
    file.close()

    -- The file has not been modified since the last sync ^
    _G.modules.cache.ucache[path] = false
end

local function loadCache(path)
    -- Get the absolute path
    local ipath = _G.workingDir .. path

    -- If the file does not exist on the disk, then we can't load it
    if not fs.exists(ipath) then return end

    -- Load the file from the disk
    local file = fs.open(ipath, "r")
    _G.modules.cache.icache[path] = file.readAll()
    file.close()

    -- The file has not been modified since the last sync ^
    _G.modules.cache.ucache[path] = false
end

-- CACHE FUNCTIONS
function _G.modules.cache.saveCache()
    -- Loop through every file stored in the cache
    for k, _ in pairs(_G.modules.cache.icache) do
        -- If the file has been modified since last sync, save it
        if _G.modules.cache.ucache[k] then
            saveFile(k)
        end
    end
end

function _G.modules.cache.writeCache(path, data)
    -- Write the data to the cache table
    _G.modules.cache.icache[path] = data

    -- Set the file status to modified
    _G.modules.cache.ucache[path] = true
end

function _G.modules.cache.readCache(path)
    -- If we don't have the file loaded into the cache already, the load it from the disk
    if _G.modules.cache.icache[path] == nil then
        loadCache(path)
    end

    -- Return the file contents
    return _G.modules.cache.icache[path]
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    -- Build our module object
    local moduleObject = {}
    moduleObject.icache = {}
    moduleObject.ucache = {}

    -- Write our module object to the global table
    _G.modules.cache = moduleObject
end

function unload()
    -- Make sure all our files are saved
    _G.modules.cache.saveCache()
end