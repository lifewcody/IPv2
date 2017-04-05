-- Update Module
-- By lifewcody
-- Last Updated 2017.04.04.21.30

local moduleInformation = {
    name = "update",
    version = "1.0.0"
}

-- LOCAL VARIABLES
local cVersion, pVersion, pType
local buildURL = "https://raw.githubusercontent.com/InZernetTechnologies/IPv2/master/buildInfo"

-- UPDATE FUNCTION
function setVersion(v)
	cVersion = v
end

function setType(t)
	pType = t
end

function checkForUpdates()
	if buildURL == nil or cVersion == nil or pType == nil then
		return false
	end

	if http.checkURL(buildURL) then
        local getVar = http.get(buildURL)
        pVersion = textutils.unserialize(getVar.readAll())[pType]
        getVar.close()
		return true
    else
		return false
    end
end

function needsUpdates()
	if cVersion >= pVersion then
		return false
	else
		return true
	end
end

function getLatestVersion()
	return pVersion
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    
end

function unload()
    
end