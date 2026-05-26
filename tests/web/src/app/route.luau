local Nova = require("@nova")

local Home = {}

--@Guard(Auth)
--@Validator(DataValidator)
function Home.Get()
    return Nova.response.json("Hello, World")
end

return Home
