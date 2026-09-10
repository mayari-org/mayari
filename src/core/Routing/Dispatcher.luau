local common = require("common")
local RouteHelper = require("./Helpers")
local BodyParser = require("../BodyParser")
local RouteMatcher = require("./Matcher")

local Exception = common.exception

local METHOD_MAP = RouteHelper.METHOD_MAP

local staticRoutes = RouteHelper.staticRoutes
local routeTreeRoot = RouteHelper.routeTreeRoot

local splitPath = RouteHelper.splitPath
local matchRoute = RouteMatcher.matchRoute

type RequestWithParams = IRequest<{ params: { [string]: any } }>

local function routerDispatcher(req: RequestWithParams)
    if #req.path > 1 and string.byte(req.path, -1) == 47 then
        req.path = string.sub(req.path, 1, -2)
    end

    if req.body and #req.body > 0 then
        local rawType: string = req.headers and req.headers["content-type"]
            or req.headers and req.headers["Content-Type"]
            or ""

        local cleanType = rawType:match("^([^;]+)") or ""
        local parser = BodyParser[cleanType]

        if parser then
            req.body = (parser :: (any) -> any)(req.body)
        end
    end

    local matchedModule = staticRoutes[req.path]
    if not matchedModule then
        local segments = splitPath(req.path)
        local matchedNode = matchRoute(routeTreeRoot, segments, req.params)

        if not matchedNode or not matchedNode.module then
            error(Exception.NotFound())
        end

        matchedModule = matchedNode.module
    end

    local method = METHOD_MAP[req.method]
    local handler = matchedModule[method] or (method == "Head" and matchedModule.Get)

    if typeof(handler) ~= "function" then
        error(Exception.HttpException(405, "Method Not Allowed"))
    end

    local fn = handler :: (RequestWithParams) -> any
    return fn(req)
end

return routerDispatcher
