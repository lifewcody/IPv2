local MAT = {}
local MATTable = {}

local cache = require("IPv2/cache")

function MAT.isInTable(mac)
    if MATTable[mac] ~= nil then
        return true
    else
        return false
    end
end

function MAT.remove(mac)
    MATTable[mac] = nil
end

function MAT.add(mac, interfaceMAC, VLAN)
    MATTable[mac] = {
        [ "VLAN" ] = VLAN,
        [ "interface" ] = interfaceMAC,
    }
end

function MAT.get(mac)
    if MAT.isInTable(mac) then
        return MATTable[mac]
    else
        return nil
    end
end

function MAT.getTable()
    return MATTable
end

function MAT.initialize()
    MATTable = cache.get("mat")
end

function MAT.save()
    cache.set("mat", MATTable)
end

function MAT.clear()
    MATTable = {}
end

return MAT