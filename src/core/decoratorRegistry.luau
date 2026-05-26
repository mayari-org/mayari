local fs = require("@adapters/fs")
local process = require("@adapters/process")

local cwd = process.cwd

-- Maps decorator type -> strategy name -> function
-- e.g. registry["Guard"]["auth"] = function(req) ... end
local registry: { [string]: { [string]: (req: any) -> any } } = {}

-- Add new decorator types here as Nova expands
local DECORATOR_DIRS: { string } = {
    "guards",
    -- "validators",
    -- "interceptors",
}

local function loadAll(mainDir: string)
    for _, dirName in DECORATOR_DIRS do
        local resolvedPath = mainDir:gsub("@c/", cwd .. "/") .. "/../" .. dirName

        if not fs.isDir(resolvedPath) then
            continue
        end

        local items = fs.readDir(resolvedPath)
        local namespace = dirName:sub(1, 1):upper() .. dirName:sub(2, -2) -- "guards" -> "Guard"
        registry[namespace] = {}

        for _, item in items do
            local name = item:match("^(.+)%.luau$")
            if name then
                local modulePath = mainDir .. "/../" .. dirName .. "/" .. name
                local ok, result = pcall(require, modulePath)
                if ok and type(result) == "function" then
                    registry[namespace][name] = result
                    print(`\27[32mLoaded {namespace}: {name}\27[0m`)
                else
                    print(`[Nova] Failed to load {namespace} '{name}': {tostring(result)}`)
                end
            end
        end
    end
end

return {
    loadAll = loadAll,
    registry = registry,
}