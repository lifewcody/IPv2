_G.iOSr = {
    [ "build"] = "2016.7.29.2.07",
    [ "buildURL"] = "http://pastebin.com/raw/d9u0SceS",
    [ "modems" ] = {}
}

_G.workingDir = "core_router/data"

os.loadAPI("modules/module_manager")
module_manager.load()

local ilog = log.log
local dir = _G.workingDir
local continue = true

function openModems()
    local sides = rs.getSides()
    local vlans = textutils.unserialize(cache.read(dir .. "/vlan"))

    for i=1, #sides do
        if peripheral.getType(sides[i]) == "modem" then
			local tmpWrap = peripheral.wrap(sides[i])
            if tmpWrap.isWireless() == false then
				_G.iOSr["modems"][sides[i]] = tmpWrap
                _G.iOSr["modems"][sides[i]].closeAll()

                if vlans[sides[i]] == nil then
                    local vtbl = {1}
                    vlans[sides[i]] = vtbl
                    ilog("INFO", "Opening " .. sides[i] .. " on VLAN 1")
                    _G.iOSr["modems"][sides[i]].open(1)
                else
                    for vl=1, #vlans[sides[i]] do
                        ilog("INFO", "Opening " .. sides[i] .. " on VLAN " .. vlans[sides[i]][vl])
                        _G.iOSr["modems"][sides[i]].open(vlans[sides[i]][vl])
                    end
                end
			else
				ilog("ERR", "Wireless modem found on " .. sides[i])
            end
        end
    end

    cache.write(dir .. "/vlan", textutils.serialize(vlans))
end

function checkOSStructure()
    if fs.exists(dir) == false then
        fs.makeDir(dir)
        ilog("ERR", "Base directory does not exist")
        ilog("ERR", "If this is your first time running this, then it is expected.")
        ilog("DEBUG", "Created base directory")
    end

    if cache.read(dir .. "/log") == nil then
        cache.write(dir .. "/log", "{}")
        ilog("ERR", "Log file does not exist")
    end

    if cache.read(dir .. "/vlan") == nil then
        cache.write(dir .. "/vlan", "{}")
        ilog("ERR", "Vlan file does not exist")
    end

    if cache.read(dir .. "/ilt") == nil then
        cache.write(dir .. "/ilt", "{}")
        ilog("ERR", "ILT file does not exist")
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
    cache.refresh()
    ilog("DEBUG", "Checking OS Folder Structure")
    checkOSStructure()
    ilog("INFO", "Done")
    ilog("DEBUG", "Opening modems")
    openModems()
    ilog("DEBUG", "Checking for updates..")
    ilog("DEBUG", "Current build: " .. _G.iOSr["build"])
    update.setURL(_G.iOSr["buildURL"])
    update.setVersion(_G.iOSr["build"])
    update.setType("router")
    update.checkForUpdates()
    if not update.needsUpdate() then
        ilog("DEBUG", "You are on the latest software release")
    else
        ilog("ERR", "You are running an out-of-date build")
    end
    ilog("INFO", "Done")
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
                ilog("INFO", "Restarting network")
                openModems()
                ilog("INFO", "Done")
            else
                ilog("ERR", "Invalid argument")
            end
        end,

        ["update"] = function()
            update.setURL(_G.iOSr["buildURL"])
            update.setVersion(_G.iOSr["build"])
            update.setType("router")
            update.checkForUpdates()
            if not update.needsUpdate() then
                print ("You have the lastest iOS")
            else
                write [[
iOS is out of date
Would you like to update? [Y/n] ]]
                local usr = read()
                if (usr == "Y" or usr == "y") then
                    print("'Updated'")
                end
            end
        end,

        ["log"] = function(arg)
            if (arg[1] == "clear") then
                log.clearLog()
                ilog("INFO", "Log file cleared")
            else
                ilog("ERR", "Usage: log <clear>")
            end
        end,

        ["vlan"] = function(arg)
            if arg[1] == nil or arg[2] == nil or arg[3] == nil then
                ilog("ERR", "Usage: vlan add  <side> <vlan #>")
                return
            end

            if string.lower(arg[1]) == "add" or string.lower(arg[1]) == "remove" then
                if #arg == 3 then
                    if not tonumber(arg[3]) then
                        ilog("ERR", "Usage: vlan add  <side> <vlan #>")
                        return
                    end

                    if tonumber(arg[3]) > 0 and tonumber(arg[3]) < 129 then
                        local isValidSide = false
                        local vlans = textutils.unserialize(cache.read(dir .. "/vlan"))

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
                                        ilog("ERR", arg[2] .. " already contains VLAN " .. arg[3])
                                        return
                                    else
                                        table.insert(vlans[arg[2]], tonumber(arg[3]))
                                    end
                                end

                                ilog("INFO", "Added VLAN " .. arg[2] .. " to side " .. arg[3])
                                cache.write(dir .. "/vlan", textutils.serialize(vlans))
                            end
                        end

                        if (isValidSide == false) then
                            ilog("ERR", "Invalid side <bottom|top|back|front|right|left>")
                        end
                    else
                        ilog("ERR", "VLAN must be between 1-128")
                    end
                else
                    ilog("ERR", "Usage: vlan add  <side> <vlan #>")
                end
            else
                ilog("ERR", "Invalid argument")
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
    local ilt = textutils.unserialize(cache.read(dir .. "/ilt"))

    if ilt == nil then
        ilt = {}
    end

    ilt[IP] = side

    cache.write(dir .. "/ilt", textutils.serialize(ilt))
end

function inILT(IP)
    local ilt = textutils.unserialize(cache.read(dir .. "/ilt"))

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
    ilog("DEBUG", "Recieved packet")

    if packetCheck(pkt) == true then
        if inILT(pkt[5]) ~= false then
            if inILT(pkt[5]) == side then
                ilog("DEBUG", "Packet coming from side in ILT")
			else
				ilog("DEBUG", "Packet in ILT -- redirecting")
				_G.iOSr["modems"][side].transmit(vlan, vlan, pkt)
            end
        else
            ilog("DEBUG", "Unknown route -- broadcasting")
			for k, v in pairs(_G.iOSr["modems"]) do
				if k ~= side then
					v.transmit(vlan, vlan, pkt)
					ilog("DEBUG", "Broadcasted on " .. k)
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
