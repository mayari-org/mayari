local collectLuauFiles = require("./RequireResolver/collectLuauFiles")
local resolveFile = require("./RequireResolver/resolveFile")

for _, filePath in collectLuauFiles("./src") do
    resolveFile(filePath, ".mayari")
end