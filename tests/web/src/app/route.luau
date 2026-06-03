local Types = require("@nova-types")
local Response = require("@utils/Response")

local Home = {}

--@Guard(Auth, Admin)
--@Interceptor(Transform)
function Home.Get()
	return Response.json("Hello, World")
end

--@Validator(createUser)
function Home.Post(req: Types.Request)
    return Response.json({ msg = "Got the Response", data = req.body })
end

return Home
