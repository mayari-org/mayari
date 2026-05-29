local registry = require("./RegistryGenerator").registry
local Response = require("@utils/Response")
local Types = require("../../types")

local function Guard(args: { string })
	return function(req: Types.Request, next: Types.Next)
        local attribute = registry["Guard"]

        if not attribute then
            return next()
        end

        local rule = attribute[args[1]]

        if not rule then
            return next()
        end

		local isAllowed = rule(req)

		if not isAllowed then
			return Response.json({ error = "Not Authorized" }, { status = 401 })
		end

		return next()
	end
end

return Guard
