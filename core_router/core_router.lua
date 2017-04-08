_G.iOS = {
    [ "dir" ] = "/" .. shell.dir() .. "/iOS/",
    [ "build" ] = "2017.04.04.03.21",
}

local cache = {}

local continue = true

function checkOSStructure()
    if fs.exists(_G.iOS.dir) == false then
        fs.makeDir(_G.iOS.dir)
        printError("Base directory does not exist")
        printError("If this is your first time running this, then it is expected.")
        printError("Created base directory")
    end
end

function startup()
    if os.loadAPI(_G.iOS.dir .. "/../../modules/module_manager.lua") == false then
	    error("[EMERG] module_manager error loading")
    end
    _G["module_manager.lua"].init()
    _G["module_manager.lua"].load()
    checkOSStructure()
    _G.modules.log.log("DEBUG", "Opening modems")
    _G.modules.modem.openModems()
    _G.modules.log.log("DEBUG", "Checking for updates..")
    _G.modules.log.log("DEBUG", "Current build: " .. _G.iOS.build)
    _G.modules.update.setType("coreRouter")
    _G.modules.update.setVersion(_G.iOS.build)
    if _G.modules.update.checkForUpdates() then
        _G.modules.log.log("DEBUG", "Latest build: " .. _G.modules.update.getLatestVersion())
        if (_G.iOS.build == _G.modules.update.getLatestVersion()) then
            _G.modules.log.log("DEBUG", "You are on the latest software release")
        else
            if (_G.iOS.build < _G.modules.update.getLatestVersion()) then
                _G.modules.log.log("ERR", "You are running an out-of-date build")
            else
                _G.modules.log.log("INFO", "You are on the development branch")
            end
        end
    end
    print(
        [[
===================================================
	
	     InZernet Router build ]] .. _G.iOS.build ..
        [[


===================================================
	]])
    parallel.waitForAny(CLI, main, saveCacheLoop)
end

local commands = {

        ["ping"] = function()
            print("Pong")
        end,

        ["exit"] = function()
			writeCache()
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
                _G.modules.log.log("INFO", "Restarting network")
                openModems()
                _G.modules.log.log("INFO", "Done")
            else
                _G.modules.log.log("ERR", "Invalid argument")
            end
        end,
		
		["cache"] = function(arg)
            if string.lower(arg[1]) == "write" then
                _G.modules.log.log("INFO", "Writing cache")
                writeCache()
                _G.modules.log.log("INFO", "Done")
            else
                _G.modules.log.log("ERR", "Usage cache <write>")
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

                _G.modules.log.clearLog()

                _G.modules.log.log("INFO", "Log file cleared")

            else
                _G.modules.log.log("ERR", "Usage: log <clear>")
            end

        end,

        ["vlan"] = function(arg)

            if arg[1] == nil or arg[2] == nil or arg[3] == nil then
                _G.modules.log.log("ERR", "Usage: vlan add  <side> <vlan #>")
                return
            end

            if string.lower(arg[1]) == "add" or string.lower(arg[1]) == "remove" then
                if #arg == 3 then

                    if not tonumber(arg[3]) then
                        _G.modules.log.log("ERR", "Usage: vlan add  <side> <vlan #>")
                        return
                    end

                    if tonumber(arg[3]) > 0 and tonumber(arg[3]) < 129 then

                        local isValidSide = false

                        for i=1, #rs.getSides() do
                            if rs.getSides()[i] == string.lower(arg[2]) then
                                isValidSide = true

                                local vlans = cache["vlans"]

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

                                        _G.modules.log.log("ERR", arg[2] .. " already contains VLAN " .. arg[3])
                                        return

                                    else
                                        table.insert(vlans[arg[2]], tonumber(arg[3]))
                                    end

                                end


                                _G.modules.log.log("INFO", "Added VLAN " .. arg[2] .. " to side " .. arg[3])

                            end
                        end

                        if (isValidSide == false) then
                            _G.modules.log.log("ERR", "Invalid side <bottom|top|back|front|right|left>")
                        end

                    else

                        _G.modules.log.log("ERR", "VLAN must be between 1-128")

                    end

                else
                    _G.modules.log.log("ERR", "Usage: vlan add  <side> <vlan #>")
                end
            else
                _G.modules.log.log("ERR", "Invalid argument")
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

function packetHandler(pkt, side, vlan)
    _G.modules.log.log("DEBUG", "Recieved packet")
    if _G.modules.packet.packetCheck(pkt) then
        if _G.modules.ilt.inILT(pkt[5]) ~= false then
            if _G.modules.ilt.inILT(pkt[5]) == side then
                log("DEBUG", "Packet coming from side in ILT")
			else
				log("DEBUG", "Packet in ILT -- redirecting")
				_G.modems[side].transmit(vlan, vlan, pkt)
            end
        else
            _G.modules.log.log("DEBUG", "Unknown route -- broadcasting")
			for k, v in pairs(_G.modems) do
				if k ~= side then
					peripheral.call(rs.getSides()[k], "transmit", vlan, vlan, pkt)
					log("DEBUG", "Broadcasted on " .. k)
				end
			end
        end
        _G.modules.ilt.addToILT(pkt[4], side)
    end

end

function main()
    while continue do
        local event, side, vlan, rFreq, pkt, dis = os.pullEvent("modem_message")
        packetHandler(pkt, side, vlan)
    end
end

function saveCacheLoop()
	while continue do
		_G.modules.cache.saveCache()
		sleep(30)
	end
end

startup()