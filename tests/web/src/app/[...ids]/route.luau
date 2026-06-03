local Types = require("@nova-types")
local Response = require("@utils/Response")
local Home = {}

function Home.Get(req: Types.RequestWith<{ ids: { string } }>)
	local userIds = req.params.ids
	return Response.json({ userIds = userIds, msg = "Found user IDs" })
end

return Home
