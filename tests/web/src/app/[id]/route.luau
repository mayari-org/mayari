local Types = require("@nova-types")
local Response = require("@utils/Response")

local Home = {}

function Home.Get(banana: Types.RequestWith<{ id: string }>)
	local userId = banana.params.id
	return Response.json({ userId = userId, msg = "Found a user ID" })
end

return Home
