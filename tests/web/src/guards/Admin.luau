local Nova = require("@nova")

local function Auth(_req: Nova.Request)
    print("Admin Check")
	return true
end

return Auth
