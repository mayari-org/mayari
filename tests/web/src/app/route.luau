local Nova = require("@nova")

local Home = {}

--@Guard(Auth, Admin)
--@Interceptor(Transform)
function Home.Get()
	return Nova.response.send("Hello, World")
end

--@Validator(createUser)
function Home.Post(req: Nova.Request)
    return Nova.response.json({ msg = "Got the Response", data = req.body })
end

return Home
