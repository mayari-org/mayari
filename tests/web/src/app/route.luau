local Nova = require("@nova")

local Home = {}

--@Guard(Auth)
function Home.Get()
	return Nova.response.json("Hello, World")
end

return Home
