require("./utils/LoadEnv")()
local routeDispatcher = require("./core/Routing/Dispatcher")
local generateRoute = require("./core/Routing/Generator")
local MainDir = require("./utils/MainDir")
local alias = require("./utils/Alias")
local attrRegistryGenerator = require("./core/Attribute/RegistryGenerator")
local RouteLogger = require("./utils/Logger")
local Chain = require("./utils/Chain")
local adpt = require("adpt")

local net = adpt.net
local json = adpt.json
local process = adpt.process

local serve = net.serve
local cwd = process.cwd

local Mayari = {}
Mayari.__index = Mayari

type MayariPrivate = typeof(Mayari)

local function statusLog(status: number, req)
    local statusColor = "\27[31m"
    if status >= 200 and status < 300 then
        statusColor = "\27[32m"
    elseif status >= 300 and status < 400 then
        statusColor = "\27[34m"
    end

    if req.path ~= "/favicon.ico" then
        local attrs = RouteLogger.getAttributes(req.path, req.method)
        local attrSuffix = attrs ~= "" and ("  " .. statusColor .. attrs .. "\27[0m") or ""
        print(string.format("[%s] %s %s%d\27[0m%s", req.method, req.path, statusColor, status, attrSuffix))
    end
end

local function devMiddleware(req: IRequest, next: INext)
    local res = next()
    local status = res.config.status or 200

    statusLog(status, req)
end

function Mayari.new(port: number, middlewares: { any }?)
    local self = setmetatable({} :: MayariPrivate, Mayari)
    self.port = port
    self.middlewares = middlewares
    self.dev = table.find(process.args, "dev") ~= nil

    alias.set("c", cwd)

    return self :: IMayari
end

function Mayari.listen(self: MayariPrivate, handler: () -> ())
    local start = os.clock()

    local mainDirName = MainDir
    local mainDir = `@c/{mainDirName}`

    local isDev = self.dev

    RouteLogger.setMiddlewares(self.middlewares or {})

    attrRegistryGenerator.loadRegistry(mainDir)
    generateRoute(mainDir, "")

    RouteLogger.flush()

    local allMiddlewares = self.middlewares and table.clone(self.middlewares) or {}

    if isDev then
        table.insert(allMiddlewares :: { IMiddleware }, 1, devMiddleware :: IMiddleware)
    end

    local rootPipeline = Chain(allMiddlewares :: { IMiddleware }, routeDispatcher)

    serve(self.port, {
        address = "0.0.0.0",
        handleRequest = function(request)
            local success, result: IResponsePayload | { statusCode: number, message: string } | any =
                pcall(rootPipeline, request)

            if not success then
                statusLog(result.statusCode or 500, request)
                if typeof(result) == "table" then
                    return {
                        status = result.statusCode,
                        body = json.encode({ error = result.message }),
                        headers = { ["Content-Type"] = "application/json" },
                    }
                else
                    local errorMessage = debug.traceback(tostring(result), 2)
                    print("\27[31m[Error]: \n" .. errorMessage .. "\27[0m")

                    return {
                        status = 500,
                        body = json.encode({ error = "Internal Server Error" }),
                        headers = { ["Content-Type"] = "application/json" },
                    }
                end
            end

            local status: number?
            local headers = nil

            if result.config then
                status = result.config.status
                headers = result.config.headers
            end

            return {
                status = status or 200,
                body = result and result.body or nil,
                headers = headers,
            }
        end,
    })

    local finish = os.clock() - start
    print(string.format("\nReady in %.4f ms\n", finish * 1000))

    if handler then
        handler()
    end
end

return Mayari
