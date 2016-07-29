_G.iOSr = {
    [ "dir"] = shell.dir(),
    [ "build"] = "2016.7.29.2.07",
    [ "buildURL"] = "http://pastebin.com/raw/d9u0SceS",
    [ "directoryStructure" ] = {
        [ "base" ] = "/iOS/router",
    },
    [ "modems" ] = {}
}

os.loadAPI("modules/cache")

local continue = true
local arguments = {...}
local log = nil

function log(...)
    if log == nil then
        log = textutils.unserialize(cache.read(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log"))
    end

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

            table.insert(log, os.clock() .. " >> " .. pString)
            cache.write(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log", textutils.serialize(log))

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
        local currentBuild = textutils.unserialize(getVar.readAll())["router"]
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
    local vlans = textutils.unserialize(cache.read(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan"))

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

    cache.write(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan", textutils.serialize(vlans))
end

function checkOSStructure()
    if cache.read(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log") == nil then
        cache.write(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log", "{}")
        log("ERR", "Log file does not exist")
    end

    if fs.exists(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"]) == false then
        fs.makeDir(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"])
        log("ERR", "Base directory does not exist")
        log("ERR", "If this is your first time running this, then it is expected.")
        log("DEBUG", "Created base directory")
    end

    if cache.read(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan") == nil then
        cache.write(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan", "{}")
        log("ERR", "Vlan file does not exist")
    end

    if cache.read(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt") == nil then
        cache.write(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt", "{}")
        log("ERR", "ILT file does not exist")
    end
end

function saveFiles()
    while continue do
        local timer = os.startTimer(5)
        repeat
            local e,t = os.pullEvent("timer")
        until t == timer
        cache.save()
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

	     InZernet Router build ]] .. _G.iOSr["build"] ..
        [[


===================================================
	]])
    parallel.waitForAny(CLI, main, saveFiles)
end

local commands = {
        ["ping"] = function()
            print("Pong")
        end,

        ["exit"] = function()
            continue = false
        end,

        ["reboot"] = function()
            os.reboot()
        end,

        ["shutdown"] = function()
            os.shutdown()
        end,

        ["networking"] = function(arg)
            if string.lower(arg[1]) == "restart" then
                log("INFO", "Restarting network")
                openModems()
                log("INFO", "Done")
            else
                log("ERR", "Invalid argument")
            end
        end,

        ["update"] = function()
            local latest = getLatestBuildNumber()
            if latest == 0 then
                print("Can't check for updates")
                return
            end
            if (_G.iOSr["build"] == latest) then
                print ("You have the lastest iOS")
            else
                if (_G.iOSr["build"] < latest) then
                    write [[
iOS is out of date
Would you like to update? [Y/n] ]]
                    local usr = read()
                    if (usr == "Y" or usr == "y") then
                        print("'Updated'")
                    end
                else
                    print ("You are on the development branch")
                end
            end
        end,

        ["log"] = function(arg)
            if (arg[1] == "clear") then
                cache.write(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/log", "{}")
                log("INFO", "Log file cleared")
            else
                log("ERR", "Usage: log <clear>")
            end
        end,

        ["vlan"] = function(arg)
            if arg[1] == nil or arg[2] == nil or arg[3] == nil then
                log("ERR", "Usage: vlan add  <side> <vlan #>")
                return
            end

            if string.lower(arg[1]) == "add" or string.lower(arg[1]) == "remove" then
                if #arg == 3 then
                    if not tonumber(arg[3]) then
                        log("ERR", "Usage: vlan add  <side> <vlan #>")
                        return
                    end

                    if tonumber(arg[3]) > 0 and tonumber(arg[3]) < 129 then
                        local isValidSide = false
                        local vlans = textutils.unserialize(cache.read(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan"))

                        for i=1, #rs.getSides() do
                            if rs.getSides()[i] == string.lower(arg[2]) then
                                isValidSide = true

                                if vlans[arg[2]] == nil then
                                    vlans[arg[2]] = {
                                        tonumber(arg[3]),
                                    }
                                else
                                    local alreadyInVlanTable = false

                                    for a=1, #vlans[arg[2]] do
                                        if vlans[arg[2]][i] == tonumber(arg[3]) then
                                            alreadyInVlanTable = true
                                        end
                                    end

                                    if alreadyInVlanTable then
                                        log("ERR", arg[2] .. " already contains VLAN " .. arg[3])
                                        return
                                    else
                                        table.insert(vlans[arg[2]], tonumber(arg[3]))
                                    end
                                end

                                log("INFO", "Added VLAN " .. arg[2] .. " to side " .. arg[3])
                                cache.write(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/vlan", textutils.serialize(vlans))
                            end
                        end

                        if (isValidSide == false) then
                            log("ERR", "Invalid side <bottom|top|back|front|right|left>")
                        end
                    else
                        log("ERR", "VLAN must be between 1-128")
                    end
                else
                    log("ERR", "Usage: vlan add  <side> <vlan #>")
                end
            else
                log("ERR", "Invalid argument")
            end
        end
}

function CLI()
    while continue do
        write("[tty1@" .. os.getComputerID() .. "]# ")

        local comm = read()
        local splitCommand = {}
        local arguments = {}

        for k in string.gmatch(comm, '[^ ]+') do
            table.insert(splitCommand, k)
        end

        for i=2, #splitCommand do
            table.insert(arguments, splitCommand[i])
        end

        if commands[splitCommand[1]] ~= nil then
            commands[splitCommand[1]](arguments)
        else
            printError(tostring(splitCommand[1]) .. ": command not found")
        end
    end
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
    local ilt = textutils.unserialize(cache.read(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt"))

    if ilt == nil then
        ilt = {}
    end

    ilt[IP] = side

    cache.write(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt", textutils.serialize(ilt))
end

function inILT(IP)
    local ilt = textutils.unserialize(cache.read(_G.iOSr["dir"] .. _G.iOSr["directoryStructure"]["base"] .. "/ilt"))

    if ilt == nil then
        ilt = {}
    end

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
