function load_module(_sPath)
    local tEnv = {}
    setmetatable( tEnv, { __index = _G } )
    local fnAPI, err = loadfile( _sPath, tEnv )
    if fnAPI then
        local ok, err = pcall( fnAPI )
        if not ok then
            printError( err )
            return false
        end
    else
        printError( err )
        return false
    end
    
    local tAPI = {}
    for k,v in pairs( tEnv ) do
        if k ~= "_ENV" then
            tAPI[k] =  v
        end
    end
	
	if tostring(type(tAPI["dependencies"])) ~= "function" then
		printError(sName .. " is missing dependencies() -- invalid module")
		return false
	end
	
	if tAPI.name() ~= nil then
		if isLoaded(tAPI.name()) then
			printError(tAPI.name() .. " is already loaded")
			return false
		end
		_G.modules[tAPI.name()] = tAPI
	else
		printError(sName .. " is missing name() -- invalid module")
		return false
	end
	
	if tAPI["dependencies"]() ~= false then
		local dependencies = tAPI["dependencies"]()
		for k, v in pairs(dependencies) do
			if isLoaded(k) ~= true then
				print("Attempting to load dependency " .. k)
				load_module(_G.iOS.dir .. "/../modules/" .. v)
			end
		end
	end
	
	
    return true
end

function isLoaded(_mName)
	if type(_G.modules[_mName]) == "table" then
		return true
	else
		return false
	end
end

function unload_module(_sName)
	if _sName ~= "_G" and type(_G.modules[_sName]) == "table" then
        _G.modules[_sName] = nil
    end
end

function init()
	_G.modules = {}
end

function load()
    local files = fs.list(_G.iOS.dir .. "/../modules")
    for i=1,#files do
        local j = files[i]
        if j ~= "module_manager.lua" then
			print("Attempting to load {" .. j .. "}")
            load_module(_G.iOS.dir .. "/../modules/" .. j)
        end
    end
end
