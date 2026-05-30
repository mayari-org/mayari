local Types = require("../types")

type Attributes = {
    [string]: ({any}) -> (Types.Request, Types.Next) -> Types.ResponsePayload?
}

--[[
    List of current implemented attributes
]]
return {
	Guard = require("@self/Guard"),
    Interceptor = require("@self/Interceptor"),
    Validator = require("@self/Validator")
} :: Attributes
