local Types = require("@nova-types")

local function Auth(_req: Types.Request)
    print("Admin Check")
	return true
end

return Auth
