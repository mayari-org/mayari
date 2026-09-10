local function normalizePath(path: string): (string, number)
    return path:gsub("\\", "/")
end

local function dirname(path: string): string
    path = normalizePath(path)

    local index = path:match("^.*()/")
    if index then
        return path:sub(1, index - 1)
    end

    return "."
end

local function relativePath(from: string, to: string): string
    from = normalizePath(from)
    to = normalizePath(to)

    local fromParts = {}
    local toParts = {}

    for part in from:gmatch("[^/]+") do
        table.insert(fromParts, part)
    end

    for part in to:gmatch("[^/]+") do
        table.insert(toParts, part)
    end

    local common = 0

    while common < #fromParts
        and common < #toParts
        and fromParts[common + 1] == toParts[common + 1]
    do
        common += 1
    end

    local result = {}

    for _ = common + 1, #fromParts do
        table.insert(result, "..")
    end

    for i = common + 1, #toParts do
        table.insert(result, toParts[i])
    end

    if #result == 0 then
        return "."
    end

    return "./" .. table.concat(result, "/")
end

return {
    transformSource = function(source: string, context): any
        local rootUri = lsp.workspace.getRootUri()
        local workspace = normalizePath(rootUri.fsPath)

        -- packages/ is directly inside the workspace root.
        local packagesPath = workspace .. "/packages/luau"

        -- Make sure packages/ exists.
        local packagesExists = pcall(function()
            lsp.fs.listDirectory(lsp.Uri.file(packagesPath))
        end)

        if not packagesExists then
            return nil
        end

        local sourceDirectory = dirname(context.filePath)
        local edits: { any } = {}

        -- Matches:
        -- require("express")
        -- require("express/router")
        -- require("lodash/utils/helpers")
        --
        -- Does not match:
        -- require("./foo")
        -- require("../foo")
        local pattern = 'require%(%s*"([^"./][^"]*)"%s*%)'

        local start = 1

        while true do
            local matchStart, matchEnd, requirePath =
                string.find(source, pattern, start)

            if not matchStart or not matchEnd then
                break
            end

            local targetPath = packagesPath .. "/" .. requirePath

            local resolvedPath = nil

            -- ---------------------------------------------------------
            -- 1. Try the exact path as a Luau file.
            --
            -- require("express/router")
            -- -> packages/express/router.luau
            -- ---------------------------------------------------------

            local filePath = targetPath .. ".luau"

            local fileExists = pcall(function()
                lsp.fs.readFile(lsp.Uri.file(filePath))
            end)

            if fileExists then
                resolvedPath = relativePath(sourceDirectory, filePath)
            else
                -- -----------------------------------------------------
                -- 2. Try it as a directory.
                --
                -- require("express")
                -- -> packages/express/
                -- -> packages/express/init.luau
                -- -----------------------------------------------------

                local directoryExists = pcall(function()
                    lsp.fs.listDirectory(lsp.Uri.file(targetPath))
                end)

                if directoryExists then
                    local initPath = targetPath .. "/init.luau"

                    local initExists = pcall(function()
                        lsp.fs.readFile(lsp.Uri.file(initPath))
                    end)

                    if initExists then
                        resolvedPath =
                            relativePath(sourceDirectory, initPath)
                    end
                end
            end

            if resolvedPath then
                local before = source:sub(1, matchStart - 1)

                local line = 1
                local lineStart = 1

                for i = 1, #before do
                    if before:sub(i, i) == "\n" then
                        line += 1
                        lineStart = i + 1
                    end
                end

                local column = matchStart - lineStart + 1
                local endColumn = matchEnd - lineStart + 2

                table.insert(edits, {
                    startLine = line,
                    startColumn = column,
                    endLine = line,
                    endColumn = endColumn,
                    newText = 'require("' .. resolvedPath .. '")',
                })
            end

            start = matchEnd + 1
        end

        if #edits == 0 then
            return nil
        end

        return edits
    end,
} :: PluginApi