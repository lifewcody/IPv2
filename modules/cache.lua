local cacheFile

function init(file)

	cacheFile = file
	
	if fs.exists(file) == false then
		cache = {}
		writeCache()
		return
	end
	
	local cf = fs.open(file, "r")
	_G["cache"] = textutils.unserialize(cf.readAll())
	
	if _G["cache"] == nil then
		_G["cache"] = {}
		writeCache()
	end
	
	cf.close()
	
end

local function isInitialized()

	if cacheFile == nil or _G["cache"] == nil then
		return false
	else
		return true
	end

end

function writeCache()

	if not isInitialized() then
		return
	end

	local cf = fs.open(cacheFile, "w")
	cf.write(textutils.serialize(_G["cache"]))
	cf.close()

end

function lCache(cName)

	if not isInitialized() then
		return
	end

	if _G["cache"][cName] == nil then
		return false
	else
		return _G["cache"][cName]
	end

end

function wCache(cName, data)
	
	if not isInitialized() then
		return
	end
	
	_G["cache"][cName] = data

end
