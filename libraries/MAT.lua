local MAT {}
local MATTable = {}

function MAT.isInTable(mac)
    if MATTable[mac] ~= nil then
        return true
    else
        return false
    end
end

function MAT.add(mac, interfaceMAC, VLAN)
    MATTable[mac] = {
        [ "VLAN" ] = VLAN,
        [ "interface" ] = interfaceMAC,
    }
end

function.MAT.get(mac)
    if MAT.isInTable(mac) then
        return MATTable[mac]
    else
        return nil
    end
end

function MAT.clear()
    MATTable = {}
end