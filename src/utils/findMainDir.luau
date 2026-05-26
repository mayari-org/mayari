local fs = require("@adapters/fs")
local process = require("@adapters/process")

local function findMainDir()
    local basePath = process.cwd
    
    local hasSrc = fs.isDir(`{basePath}/src`)
    local hasApp = fs.isDir(`{basePath}/app`)

    if hasSrc and hasApp then
        print("Found both src/ and app/ on your project directory. Nova will try reading the src/ only.")
    end

    if hasSrc then
        return "src/app"
    end
    
    return "app"
end

return findMainDir
