type Attributes = {
    [string]: ({ any }) -> (IRequest, INext) -> IResponsePayload?,
}

--[[
    List of current implemented attributes
]]
return {
    Guard = require("@self/Guard"),
    Interceptor = require("@self/Interceptor"),
    Validator = require("@self/Validator"),
} :: Attributes
