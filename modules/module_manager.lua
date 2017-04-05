-- Load the module with the path supplied
function load_module(_sPath)

	-- sName is the name of the file, not the full filename
	local sName = fs.getName(_sPath)

	-- tbh idk what this does, but i copied it from CC's bios
    local tEnv = {}
    setmetatable( tEnv, { __index = _G } )

	-- Checks the file to make sure it's error free
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
    

	-- For each public function, but that into the table tAPI	
    local tAPI = {}
    for k,v in pairs( tEnv ) do
        if k ~= "_ENV" then
            tAPI[k] =  v
        end
    end

	-- Make sure that the 3 required functions are there, if not stop loading.
	if type(tAPI.getModuleInformation) ~= "function" or type(tAPI.load) ~= "function" or type(tAPI.unload) ~= "function" then
		printError(sName .. " is not a properly formatted module -- not loaded")
		return false
	end

	-- Load module (from tAPI) to the correct name (from the function getModuleInformation())
	_G.modules[tAPI.getModuleInformation().name] = tAPI
	

	-- Make sure the dependencies is either false or not there (nil)
	if not tAPI.getModuleInformation().dependencies == false and not tAPI.getModuleInformation().dependencies ~= nil then
		-- For each dependency
		for k, v in pairs(tAPI.getModuleInformation().dependencies) do
			-- If it is not loaded, attempt to load the module
			if not isLoaded(k) == true then
				print("Attempting to load dependency " .. k)
				load_module(_G.iOS.dir .. "/../modules/" .. v)
			else
				print("Dependency already loaded : " .. k)
			end
		end
	end
end

-- check to see if the module is already loaded
function isLoaded(module)
	if type(_G.modules[module]) == "table" then
		return true
	else
		return false
	end
end

function unload_module(_sName)
	if _sName ~= "_G" and type(_G.modules[_sName]) == "table" then
		-- Call our unload() method
		_G.moduled[_sName].unload()
		-- Actually clear it out
        _G.modules[_sName] = nil
    end
end

-- Initialize the Global module table
function init()
	_G.modules = {}
end

-- For every module in /modules (except MM and the example) load it
function load()
    local files = fs.list(_G.iOS.dir .. "/../modules")
    for i=1,#files do
        local j = files[i]
        if j ~= "module_manager.lua" and j ~= "example.lua" then
			print("Attempting to load {" .. j .. "}")
            load_module(_G.iOS.dir .. "/../modules/" .. j)
        end
    end
end
