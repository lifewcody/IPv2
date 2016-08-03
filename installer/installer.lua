local programs
local program

function getPrograms()
    local p = http.get("https://raw.githubusercontent.com/InZernetTechnologies/IPv2/master/installer/programs.ccon")
    programs = textutils.unserialize(p.readAll())
    p.close()
end

function printPrograms()
    if not programs then return end
    for i=1,#programs do
        print("[" .. i .. "] " .. programs[i][1])
    end
end

function inputProgram()
    term.write("[?] Select a program to install: ")
    program = tonumber(read())
    if not program or program <= 0 or program > #programs then
        print("[!] Invalid program number")
        inputProgram()
    end
end

function downloadFile(url, path)
    local u = http.get("https://raw.githubusercontent.com/InZernetTechnologies/IPv2/master/" .. url)
    local f = fs.open(path, "w")
    f.write(u.readAll())
    f.close()
    u.close()
end

function installProgram()
    local i = programs[program][3]
    local j = i .. "/" .. i .. ".lua"
    downloadFile(programs[program][2], j)
    print("[*] Downloaded " .. j)
end

function installModules()
    local i = http.get("https://raw.githubusercontent.com/InZernetTechnologies/IPv2/master/modules/module_list.ccon")
    local mod = textutils.unserialize(i.readAll())
    i.close()

    for j=1,#mod do
        local k = "modules/" .. mod[j][3]
        if not fs.exists(k) then
            downloadFile(mod[j][2], k)
            print("[*] Downloaded " .. k)
        end
    end
end

function main()
    term.clear()
    term.setCursorPos(1, 1)

    print("=# InZernet Protocol V2 Installer #=")
    print("")
    print("[*] Getting Program List...")

    getPrograms()

    print("")
    printPrograms()
    print("")

    inputProgram()

    print("")
    print("[*] Installing " .. programs[program][1] .. "...")

    installProgram()
    installModules()

    print("")
    print("[*] Successfully installed " .. programs[program][1])
end

main()
