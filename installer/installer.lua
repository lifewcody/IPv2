local programs
local program

function getPrograms()
    local p = http.get("https://raw.githubusercontent.com/InZernetTechnologies/IPv2/master/installer/programs.ccon")
    programs = textutils.unserialize(p.readAll())
end

function printPrograms()
    if not programs then return end
    for i=1,#programs do
        print("[" .. i .. "] " .. programs[i][1])
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
    term.write("[?] Select a program to install: ")
    program = tonumber(read())

    print("You selected " .. program .. " which is the " .. programs[program][1])
end

main()
