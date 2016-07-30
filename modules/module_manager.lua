function load_module(path)
    if fs.exists(path) then
        os.loadAPI(path)
    end
end

function load()
    local files = fs.list("/modules")
    for i=1,#files do
        local j = files[i]
        if j ~= "module_manager" then
            load_module("/modules/" .. j)
        end
    end
end
