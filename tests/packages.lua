for k, v in pairs(package.loaded) do
    print(k .. " > " .. tostring(v))
end
print("-------------------------------------------")
local ethernet = require("IPv2/ethernet")
for k, v in pairs(package.loaded["IPv2/ethernet"]) do
    print(k .. " > " .. tostring(v))
end