local Types = require("@nova-types")

local schema: Types.ValidatorSchema = {
    body = {
        username = { type = "string", required = true, min = 3, max = 20 },
        age = { type = "number", required = true, min = 18 },
        email = { type = "string", required = true, pattern = "^[^@%s]+@[^@%s]+%.[^@%s]+$" },
    }
}

return schema