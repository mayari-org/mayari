local fs = require("@adapters/fs")
local process = require("@adapters/process")
local routing = require("./routing")
local decorator = require("./decorator")
local decoratorRegistry = require("./decorators")
local chain = require("../utils/chain")

local readDir = fs.readDir
local metadata = fs.metadata
local cwd = process.cwd
local registerRoute = routing.registerRoute

local function buildDecoratorMiddlewares(decoratorStrings: { string }): { any }
    local middlewares = {}

    for _, raw in decoratorStrings do
        local parsedDecor = decorator.parseDecorator(raw)

        if parsedDecor then
            local factory = (decoratorRegistry :: any)[parsedDecor.name] :: (any) -> any

            if not factory then
                print(`[Nova] Unknown decorator: @{parsedDecor.name} — skipping`)
            else
                table.insert(middlewares, factory(parsedDecor.args))
            end
        end
    end

    return middlewares
end

local function applyDecorators(routeModule: any, extractedDecorators: { [string]: { string } })
    local METHOD_NAMES = { "Get", "Post", "Put", "Delete", "Patch", "Head" }

    for _, method in METHOD_NAMES do
        local handler = routeModule[method]
        if type(handler) ~= "function" then
            continue
        end

        local decoratorStrings: { string }? = nil
        for fnName, decs in extractedDecorators do
            local tail = fnName:match("[:.]([%w_]+)$") or fnName
            if tail == method then
                decoratorStrings = decs
                break
            end
        end

        if decoratorStrings and #decoratorStrings > 0 then
            local middlewares = buildDecoratorMiddlewares(decoratorStrings)
            if #middlewares > 0 then
                routeModule[method] = chain(middlewares, handler)
            end
        end
    end
end

local function generateRoute(currentDir: string, currentRoute: string)
    local resolvedDir = currentDir:gsub("@c/", cwd .. "/")
    local items = readDir(resolvedDir)

    for _, item in ipairs(items) do
        local path = currentDir .. "/" .. item
        local resolvedPath = path:gsub("@c/", cwd .. "/")

        if item == "route.luau" then
            local source = fs.readFile(resolvedPath)
            local extractedDecorators = decorator.extractDecorator(source)

            local modulePath = currentDir .. "/route"
            
            local routeKey = currentRoute == "" and "/" or currentRoute
            
            local routeModule = require(modulePath) :: any

            applyDecorators(routeModule, extractedDecorators)

            registerRoute(routeKey, routeModule)
            
            print(`\27[32mRegistered Route: {routeKey}\27[0m`)

        elseif metadata(resolvedPath).kind == "dir" or metadata(resolvedPath).kind == "directory" then
            local nextRoute = currentRoute .. "/" .. item
            generateRoute(path, nextRoute)
        end
    end
end

return generateRoute