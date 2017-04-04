local w,h = term.getSize()

local siteHistory = {}
local siteIndex = 0
local backBtnActive = true
local forwardBtnActive = false
local urlBox = "Search..."
local urlBoxSelected = true
local continue = true

function update()
    backBtnActive = siteIndex > 1
    forwardBtnActive = siteIndex < #siteHistory
end

function draw()
    term.setBackgroundColor(colors.lightBlue)
    term.clear()

    term.setBackgroundColor(colors.lightGray)
    for x=1,w do
        term.setCursorPos(x, 1)
        term.write(" ")
    end

    --Back Btn
    term.setCursorPos(2, 1)
    term.setTextColor(backBtnActive and colors.blue or colors.white)
    term.write("<")

    --Forward Btn
    term.setCursorPos(4, 1)
    term.setTextColor(forwardBtnActive and colors.blue or colors.white)
    term.write(">")

    --Search Bar
    term.setBackgroundColor(colors.white)
    for x=7,w-6 do
        term.setCursorPos(x, 1)
        term.write(" ")
    end
    term.setTextColor(colors.lightGray)
    term.setCursorPos(8, 1)
    term.write(urlBox)

    --Menu Btn
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.white)
    term.setCursorPos(w-3, 1)
    term.write("=")

    --Exit Btn
    term.setBackgroundColor(colors.red)
    term.setCursorPos(w, 1)
    term.write(" ")
end

function main()
    while continue do
        update()
        draw()
        sleep(0.0)
    end
end

function input()
    while true do
    end
end

parallel.waitForAny(main, input)
