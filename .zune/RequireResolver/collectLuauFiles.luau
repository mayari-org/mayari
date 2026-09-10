local fs = zune.fs

local function collectLuauFiles(dirPath: string, excludeDirs: { string }?): { string }
    if not fs.stat(dirPath) or fs.stat(dirPath).kind ~= "directory" then
        error("Invalid directory path: " .. dirPath)
    end

    local excludeSet: {[string]: boolean}? = nil

    if excludeDirs then
        excludeSet = {}

        for _, excluded in excludeDirs do
            (excludeSet :: {[string]: boolean})[excluded] = true
        end
    end

    local results = {}

    local function walk(dir: string)
        if excludeSet and excludeSet[dir] then
            return
        end

        local entries = fs.entries(dir)

        for _, entry in entries do
            local fullPath = fs.path.join(dir, entry.name)

            if entry.kind == "directory" then
                walk(fullPath)
            elseif entry.kind == "file"
                and fullPath:match("%.luau$")
            then
                table.insert(results, fullPath)
            end
        end
    end

    walk(dirPath)

    return results
end

return collectLuauFiles
