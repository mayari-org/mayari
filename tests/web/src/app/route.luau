local Nova = require("@nova")

local Home = {}

--@Guard(Auth, Admin)
--@Interceptor(Transform)
function Home.Get()
	return Nova.response.send("Hello, World")
end

return Home
