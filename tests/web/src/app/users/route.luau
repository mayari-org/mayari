local Response = require("@utils/Response")
local UserService = require("./users.service")

local Users = {}

function Users.Get()
	return Response.json(UserService.getUser(123))
end

return Users
