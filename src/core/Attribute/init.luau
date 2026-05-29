type Attributes = {
    [string]: ({any}) -> (any, any) -> any
}

--[[
    List of current implemented attributes
]]
return {
	Guard = require("@self/Guard"),
} :: Attributes
