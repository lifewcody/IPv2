function load_module(path)
    if fs.exists(path) then
        os.loadAPI(path)
    end
end

function load(...)
    local files = fs.list(_G.iOS.dir .. "/../modules")
    for i=1,#files do
        local j = files[i]
        if j ~= "module_manager.lua" then
            load_module(_G.iOS.dir .. "/../modules/" .. j)
			print("Attempting to load {" .. j .. "}")
        end
    end
end
