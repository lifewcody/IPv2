local io = require("io")
local term = require("term")
local component = require("component")
local configuration = require("IPv2/configuration")
local log = require("IPv2/log")
local MAT = require("IPv2/MAT")
local version = "2017.09.06.04.49"
local running = true

commands = {
    ["ifconfig"] = function()
        for k, v in pairs(_G.modems) do
            print(k)
            print("         RX: " .. v["RX"] .. " bytes")
            print("         TX: " .. v["TX"] .. " bytes")
            local VLANS = ""
            for a, b in pairs(v["VLAN"]) do
                VLANS = VLANS .. " " .. tostring(b)
            end
            print("         VLANS: " .. VLANS)
        end
    end,
    ["help"] = function()
        print("Commands available:")
        for k, v in pairs(commands) do
            print("         " .. k)
        end
    end,
    ["exit"] = function()
        running = false
    end,

    ["vlan"] = function(args)
        if #args == 0 then
            print("vlan <interface> <add|remove> <vlan>")
        elseif #args >= 1 then
            if args[1] ~= nil and args[2] ~= nil and tonumber(args[3]) then
                local int = component.get(args[1])
                if int ~= nil then

                else
                    print("Invalid interface")
                end
                if #args >= 2 then
                    if args[2] == "add" or args[2] =="remove" then
                        if args[2] == "add" then
                            if _G.modems[int] == nil then
                                print("Interface does not exist")
                                return false
                            end
                            table.insert(_G.modems[int]["VLAN"], tonumber(args[3]))
                            print("Succesfully added VLAN " .. args[3] .. " on " .. int)
                        end
                        if args[2] == "remove" then
                            local successRemove = false
                            for k, v in pairs(_G.modems[int]["VLAN"]) do
                                if tonumber(v) == tonumber(args[3]) then
                                    _G.modems[int]["VLAN"][k] = nil
                                    print("Succesfully removed VLAN " .. args[3] .. " from " .. int)
                                    successRemove = true
                                end
                            end
                            if not successRemove then
                                print("There was no VLAN " .. args[3] .. " on " .. int)
                            end
                        end
                    else
                        print("vlan <interface> <add|remove> <vlan>")
                    end
                end
            end
        end
    end,
    ["access-list"] = function(args)
        if args[1] == "show-all" then
            for k, v in pairs(_G.configuration["access-list"]) do
                print(k .. ":")
                print(" " .. " [" .. v["mode"] .. "] >> " ..  v["type"])
                print(" " .. " [" .. v["source"] .. "] >> [" .. v["destination"] .. "]")
            end
            return true
        end
        if args[1] == "save" then
            configuration.save()
            print("Configuration saved")
            return true
        end
        if args[1] == "remove" then
            if _G.configuration["access-list"][tonumber(args[2])] ~=nil then
                _G.configuration["access-list"][tonumber(args[2])] = nil
                return true
            end
        end
        if #args >= 4 then
            if args[1] == "ip" or args[1] == "mac" or args[1] == "show-all" then
                if args[2] ~=nil then
                    if args[3] ~=nil then
                        if args[4] ~= nil then
                            configuration.accessList.add(args[1], args[2], args[3], args[4])
                            print("Access list added succesfully")
                        end
                    end
                end
            end
        else
            print("access-list <ip|mac<show-all><remove>> <allow|deny<id>> <source ip|source mac|any> <destination ip|source mac|any>")
        end
    end,

    ["network"] = function(args)
        if #args == 1 then
            if args[1] == "reload" then
                local modem = require("IPv2/modem")
                modem.initialize()
                modem.open()
            elseif args[1] == "save" then
                local modem = require("IPv2/modem")
                modem.save()
                print("Modem configuration saved")
            end
        else
            print("network <reload>")
        end
    end,

    ["log"] = function(args)
        if args[1] == "set" then
            if args[2] == "level" then
                log.setLevel(tonumber(args[3]))
                print("Log level set to " .. args[3])
                return true
            end
        end
        print("log <set> <level> <log level>")
    end,
    ["mat"] = function(args)
        if args[1] == "show-all" then
            for k, v in pairs(MAT.getTable()) do
                print(k .. ":")
                print(" " .. " [" .. v["interface"] .. "] >> " ..  v["VLAN"])
            end
            return true
        end
        if args[1] == "clear" then
            MAT.clear()
            print("MAT cleared successfully")
            return true
        end
        if args[1] == "remove" then
            if args[2] ~= nil then
                if MAT.isInTable(args[2]) then
                    MAT.remove(args[2])
                    print("[" .. args[2] .. "] removed succesfully")
                else
                    print("[" .. args[2] .. "] is not in the MAT")
                end
                return true
            end
        end
        print("mat <show-all|clear|remove> <mac>")
    end,
}

print("Router v. " .. version)
print('Type \'exit\' at any point to exit.')

while running do
    term.write("Router#> ")
    command = io.read()
    local tmpComTbl = {}
    local tmpComTbl2 = {}
   
    for k in string.gmatch(command, '[^ ]+') do
      table.insert(tmpComTbl, k)
    end
   
    for i=2, #tmpComTbl do
      table.insert(tmpComTbl2, tmpComTbl[i])
    end
   
    if commands[tmpComTbl[1]] ~= nil then
      local status, err = pcall(commands[tmpComTbl[1]], tmpComTbl2)
      if not status then
        print("ERROR: " .. err)
      end
    else
      print('Command not found.')
    end
end