local registry = require("./RegistryGenerator").registry
local Response = require("@utils/Response")
local Types = require("../../types")

local function Guard(args: { string })
    return function(req: Types.Request, next: Types.Next)
        local attribute = registry["Guard"]

        if not attribute then
            return next()
        end

        for _, arg in args do
            local rule = attribute[arg]

            if not rule then
                continue
            end

            local isAllowed = rule(req)

            if not isAllowed then
                return Response.json({ error = "Not Authorized" }, { status = 401 })
            end
        end

        return next()
    end
end

return Guard
