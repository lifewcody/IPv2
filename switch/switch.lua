_G.iOSr = {
    [ "dir"] = shell.dir(),
    [ "build"] = "2016.7.29.2.07",
    [ "buildURL"] = "http://pastebin.com/raw/d9u0SceS",
    [ "directoryStructure" ] = {
        [ "base" ] = "/iOS/switch",
    },
    [ "modems" ] = {}
}

local cache = {}

local continue = true

function log(...)

    local tmpLog

    if fs.exists(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log") then

        local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log", "r")
        tmpLog = textutils.unserialize(t.readAll())
        t.close()

    else

        tmpLog = {}

    end

    local arguments = {...}


    if arguments[1] == "ERR" or arguments[1] == "DEBUG" or arguments[1] == "INFO" then
        if #arguments > 1 then

            local pString = ""
            local oldColor = term.getTextColor()

            for k, v in pairs(arguments) do
                if #pString == 0 then
                    pString = "[" .. v .. "]"
                else
                    pString = pString .. " [" .. v .. "]"
                end
            end

            table.insert(tmpLog, os.clock() .. " >> " .. pString)

            local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log", "w")
            t.write(textutils.serialize(tmpLog))
            t.close()

            if arguments[1] == "ERR" then

                term.setTextColor(colors.red)
                print(pString)

            elseif arguments[1] == "DEBUG" then

                term.setTextColor(colors.blue)
                print(pString)

            elseif arguments[1] == "INFO" then

                term.setTextColor(colors.yellow)
                print(pString)

            end

            term.setTextColor(oldColor)

        else
            local oldColor = term.getTextColor()
            term.setTextColor(colors.red)
            print("[ERR] Log must have more than one argument")
            term.setTextColor(oldColor)
        end
    else
        local oldColor = term.getTextColor()
        term.setTextColor(colors.red)
        print("[ERR] Invalid first argument")
        term.setTextColor(oldColor)
    end
end

function getLatestBuildNumber()
    if http.checkURL(_G.iOSr["buildURL"]) then
        log("DEBUG", "checkURL true")
        local headers = {
            [ "User-Agent" ] = "iOS/" .. _G.iOSr["build"] .. " (" .. os.version() .. ")"
        }
        local getVar = http.get(_G.iOSr["buildURL"], headers)
        local currentBuild = textutils.unserialize(getVar.readAll())["switch"]
        log("DEBUG", "Latest build: " .. currentBuild)
        getVar.close()
        return currentBuild
    else
        log("INFO", "checkURL false")
        return 0
    end
end

function openModems()
    local sides = rs.getSides()

    local vlans
    local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan", "r")
    vlans = textutils.unserialize(t.readAll())
    t.close()

    for i=1, #sides do
        if peripheral.getType(sides[i]) == "modem" then
			local tmpWrap = peripheral.wrap(sides[i])
            if tmpWrap.isWireless() == false then
				_G.iOSr["modems"][sides[i]] = tmpWrap
                _G.iOSr["modems"][sides[i]].closeAll()

                if vlans[sides[i]] == nil then

                    local vtbl = {1}

                    vlans[sides[i]] = vtbl

                    log("INFO", "Opening " .. sides[i] .. " on VLAN 1")

                    _G.iOSr["modems"][sides[i]].open(1)

                else

                    for vl=1, #vlans[sides[i]] do

                        log("INFO", "Opening " .. sides[i] .. " on VLAN " .. vlans[sides[i]][vl])

                        _G.iOSr["modems"][sides[i]].open(vlans[sides[i]][vl])
                    end

                end
			else
				log("ERR", "Wireless modem found on " .. sides[i])
            end
        end
    end

    local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan", "w")
    t.write(textutils.serialize(vlans))
    t.close()

end

function checkOSStructure()
    if fs.exists(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log") == false then
        local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log", "w")
        t.write("{}")
        t.close()
        log("ERR", "Log file does not exist")
    end
    if fs.exists(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"]) == false then
        log("ERR", "Base directory does not exist")
        log("ERR", "If this is your first time running this, then it is expected.")
        fs.makeDir(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"])
        log("DEBUG", "Created base directory")
    end
    if fs.exists(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan") == false then
        log("ERR", "Vlan file does not exist")
        local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan", "w")
        t.write("{}")
        t.close()
    end

    if fs.exists(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt") == false then
        log("ERR", "ILT file does not exist")
        local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt", "w")
        t.write("{}")
        t.close()
    end
end

function startup()
    log("DEBUG", "Checking OS Folder Structure")
    checkOSStructure()
    log("INFO", "Done")
    log("DEBUG", "Opening modems")
    openModems()
    log("DEBUG", "Checking for updates..")
    log("DEBUG", "Current build: " .. _G.iOSr["build"])
    local latest = getLatestBuildNumber()
    if (_G.iOSr["build"] == latest) then
        log("DEBUG", "You are on the latest software release")
    else
        if (_G.iOSr["build"] < latest) then
            log("ERR", "You are running an out-of-date build")
        else
            log("INFO", "You are on the development branch")
        end
    end
    log("INFO", "Done")
    print(
        [[
===================================================

	     InZernet Switch build ]] .. _G.iOSr["build"] ..
        [[


===================================================
	]])
    main()
end

function IPCheck(ip)
    local pIP = {}

    if ip == nil then
        return 103
    end
    for octect in string.gmatch(ip, "[^.]+") do
        table.insert(pIP, octect)
    end
    if #pIP == 2 then
        if tonumber(pIP[1]) and tonumber(pIP[2]) then
            return true
        else
            return 102
        end
    else
        return 101
    end

end

function packetCheck(packet)

    if #packet == 6 then

        if packet[1] == 2 then

            if packet[2] == 1 or packet[2] == 6 or packet[2] == 17 then

                if packet[3] >= 1 then

                    if IPCheck(packet[4]) == true then

                        if IPCheck(packet[5]) == true then

                            if packet[6] ~= nil then

                                return true

                            else
                                return 106
                            end
                        else
                            return 105
                        end
                    else
                        return 104
                    end
                else
                    return 103
                end
            else
                return 102
            end
        else
            return 101
        end
    else
        return 100
    end
end

function addToILT(IP, side)

    local ilt

    local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt", "r")
    ilt = textutils.unserialize(t.readAll())
    t.close()

    if ilt == nil then
        ilt = {}
    end

    ilt[IP] = side

    local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt", "w")
    t.write(textutils.serialize(ilt))
    t.close()

end

function inILT(IP)

    local ilt

    local t = fs.open(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt", "r")
    ilt = textutils.unserialize(t.readAll())
    t.close()

    if IP == nil then
        return false
    end

    if ilt[IP] == nil then
        return false
    else
        return ilt[IP]
    end

end

function packetHandler(pkt, side, vlan)

    log("DEBUG", "Recieved packet")

    if packetCheck(pkt) == true then
        if inILT(pkt[5]) ~= false then
            if inILT(pkt[5]) == side then
                log("DEBUG", "Packet coming from side in ILT")
			else
				log("DEBUG", "Packet in ILT -- redirecting")
				_G.iOSr["modems"][side].transmit(vlan, vlan, pkt)
            end
        else
            log("DEBUG", "Unknown route -- broadcasting")
			for k, v in pairs(_G.iOSr["modems"]) do
				if k ~= side then
					v.transmit(vlan, vlan, pkt)
					log("DEBUG", "Broadcasted on " .. k)
				end
			end
        end
        addToILT(pkt[4], side)
    end

end

function main()
    while continue do
        local event, side, vlan, rFreq, pkt, dis = os.pullEvent("modem_message")
        packetHandler(pkt, side, vlan)
    end
end

startup()
