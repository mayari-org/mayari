local Nova = require("@nova")

local function Auth(_req: Nova.Request)
	return false
end

return Auth
