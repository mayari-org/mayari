local Nova = require("@nova")

local function Transform(_req: Nova.Request, next: Nova.Next)
    next()
    return Nova.response.send("Hello, Interceptor")
end

return Transform
