local fs = zune.fs

-- ============================================================
-- Checker
-- ============================================================

local function needsResolution(requirePath: string): boolean
    if requirePath == "" then
        return false
    end

    local first = requirePath:sub(1, 1)

    return first ~= "@" and first ~= "."
end

-- Dynamic packages/luau/ discovery, walks up from the file until it finds a packages/luau/ dir)
local function findPackagesDir(startDir: string): string?
    local dir = startDir
    local isAbsolute = fs.path.isAbsolute(startDir)

    while true do
        local candidate = fs.path.join(dir, "packages/luau")

        if fs.stat(candidate).kind == "directory" then
            return candidate
        end

        if not isAbsolute and dir == "." then
            return nil
        end

        local parent = fs.path.dirname(dir)

        if not parent then
            if isAbsolute then
                return nil
            end

            parent = "."
        end

        if parent == dir then
            return nil
        end

        dir = parent
    end
end

local function resolvePackage(packagesPath: string, name: string): string?
    local exactFile = fs.path.join(packagesPath, name .. ".luau")

    if fs.stat(exactFile).kind == "file" then
        return exactFile
    end

    local dirPath = fs.path.join(packagesPath, name)

    if fs.stat(dirPath).kind == "directory" then
        local initFile = fs.path.join(dirPath, "init.luau")

        if fs.stat(initFile).kind == "file" then
            return dirPath
        end
    end

    return nil
end

local function buildSkipMask(source: string): {boolean}
    local mask = {}
    local i = 1
    local len = #source

    while i <= len do
        local c = source:sub(i, i)

        if c == "-" and source:sub(i + 1, i + 1) == "-" then
            local eqSign, afterOpen = source:match("^%-%-%[(=*)%[()", i)

            if eqSign then
                local closePattern = "%]" .. eqSign:gsub("%%", "%%%%") .. "%]"
                local _, closeEnd = source:find(closePattern, afterOpen)
                local segEnd = closeEnd or len

                for j = i, segEnd do
                    mask[j] = true
                end

                i = segEnd + 1
            else
                local lineEnd = source:find("\n", i) or (len + 1)

                for j = i, lineEnd - 1 do
                    mask[j] = true
                end

                i = lineEnd
            end
        elseif c == "[" then
            local eqSign, afterOpen = source:match("^%[(=*)%[()", i)

            if eqSign then
                local closePattern = "%]" .. eqSign:gsub("%%", "%%%%") .. "%]"
                local _, closeEnd = source:find(closePattern, afterOpen)
                local segEnd = closeEnd or len

                for j = i, segEnd do
                    mask[j] = true
                end

                i = segEnd + 1
            else
                i += 1
            end
        elseif c == '"' or c == "'" then
            local quote = c
            local j = i + 1

            while j <= len do
                local cj = source:sub(j, j)

                if cj == "\\" then
                    j += 2
                elseif cj == quote then
                    j += 1
                    break
                else
                    j += 1
                end
            end

            for k = i, math.min(j - 1, len) do
                mask[k] = true
            end

            i = j
        else
            i += 1
        end
    end

    return mask
end

-- ============================================================
-- Resolver
-- ============================================================

local REQUIRE_PATTERN = 'require%(%s*"([^"]+)"%s*%)'

-- source: the file's content, as text.
-- filePath: where that content came from — used only to find packages/luau/
-- and to compute the correct ./ or ../ depth. Nothing is hardcoded.
local function resolveRequire(source: string, filePath: string): string?
    local requirerDir = fs.path.dirname(filePath) or "."
    local packagesPath = nil -- resolved lazily, only if actually needed

    local mask = buildSkipMask(source)
    local resolvedCount = 0
    local out = {}
    local pos = 1
    local len = #source

    while pos <= len do
        local matchStart, matchEnd, requirePath = source:find(REQUIRE_PATTERN, pos)

        if not matchStart or not matchEnd then
            out[#out + 1] = source:sub(pos)
            break
        end

        out[#out + 1] = source:sub(pos, matchStart - 1)

        if mask[matchStart] or not needsResolution(requirePath) then
            out[#out + 1] = source:sub(matchStart, matchEnd)
        else
            -- Only now, on first bare-name require, do we actually need
            -- packages/luau to exist.
            if not packagesPath then
                packagesPath = findPackagesDir(requirerDir)

                if not packagesPath then
                    error(
                        `Cannot resolve require("{requirePath}"): no "packages/luau" directory found (searched upward from "{requirerDir}")`
                    )
                   return nil 
                end
            end

            local targetPath = resolvePackage(packagesPath :: string, requirePath)

            if not targetPath then
                error(
                    `Cannot resolve require("{requirePath}"): no package named "{requirePath}" was found in "{packagesPath}" (required from "{filePath}")`
                )
                return nil
            end

            local relativePath = fs.path.relative(requirerDir, targetPath)

            if relativePath:sub(1, 1) ~= "." then
                relativePath = "./" .. relativePath
            end

            if relativePath:sub(-5) == ".luau" then
                relativePath = relativePath:sub(1, -6)
            end

            resolvedCount += 1
            out[#out + 1] = 'require("' .. `../{relativePath}` .. '")'
        end

        pos = matchEnd + 1
    end

    if resolvedCount == 0 then
        return nil
    end

    return table.concat(out)
end

--[[
    Resolves the require path from the srouce at the given `filePath`, 
    And generated resolved files to the `outDir` path.

    @param filePath The path to the Luau file.
    @param outDir The path where resolved Luau file will be stored.
    @return A `string` (the path where the resolved file is stored) or a `nil`

    **Example**
    ```luau
        print(Resolver.resolveFile("./src/index.luau", "./dist"))
    ```
]]
local function resolveFile(filePath: string, outDir: string): string?
    local source = fs.readFileSync(filePath)

    local resolved = resolveRequire(source, filePath) or source

    if filePath:sub(1, 2) == "./" then
        filePath = filePath:sub(3)
    end

    if not outDir then
        outDir = "./dist"
    end

    if not (outDir:sub(1, 2) == "./") then
        outDir = `./{outDir}`
    end

    local directory = fs.path.dirname(filePath) or "."
    local stem = fs.path.stem(filePath)
    local outputPath = fs.path.join(directory, stem .. ".luau")

    fs.makeDir(`{outDir}/{directory}`, true)
    fs.createFile(`{outDir}/{outputPath}`, { truncate = false })
    fs.writeFileSync(`{outDir}/{outputPath}`, resolved)

    return `{outDir}/{outputPath}`
end

return resolveFile
