local Response = require("../../utils/response")
local decoratorRegistry = require("../decoratorRegistry")

local function Guard(args: { string })
    local strategy = decoratorRegistry.registry["Guard"][args[1]]

    return function(req: any, next: () -> ())

        local authorized = strategy(req)

        if not authorized then
            return Response.json({ error = "Unauthorized" }, { status = 401 })
        end

        next()
        return
    end
end

return Guard
