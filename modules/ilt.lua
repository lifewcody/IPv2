function dependencies()
	return {
		["cache"] = "cache.lua"
	}
end

function name()
	return "ilt"
end

local function checkILT()
    if not _G.ilt then
		local n = _G["cache.lua"].readCache("ilt")
		if n then
			_G.ilt = textutils.unserialize(n)
		else
			_G.ilt = {}
		end
	end
end

function addToILT(IP, side)
    checkILT()
    _G.ilt[IP] = side
    cache.write("ilt", textutils.serialize(_G.ilt))
end

function inILT(IP)
    checkILT()
    return IP == nil and nil or _G.ilt[IP]
end
