local Types = require("@nova-types")

local function Transform(_req: Types.Request, next: Types.Next)
    next()
end

return Transform
