-- Example Module
-- By Assossa
-- Last Updated 4/4/17

-- Required
function getModuleInformation()
    return {
        name = "example",
        version = "1.0.0",
        dependencies = {"module1", "module2"}
    }
end

--Required
function load()
    print("Module loaded!")
end

--Required
function unload()
    print("Module unloaded!")
end