local pastebinURL, cVersion, pVersion, pType

function setURL(u)
	pastebinURL = u
end

function setVersion(v)
	cVersion = v
end

function setType(t)
	pType = t
end

function checkForUpdates()
	if pastebinURL == nil or cVersion == nil or pType == nil then
		return false
	end

	if http.checkURL(pastebinURL) then
        local getVar = http.get(pastebinURL)
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
