local serde = require("../adapter/serde")
local fs = require("../adapter/fs")
local process = require("../adapter/process")

local function generateAlias()
	local luauarcPath = process.cwd .. "/.luaurc"

	if not luauarcPath then
		error("Luaurc file is not found in your project.")
	end

	local luaurcJson = fs.readFile(luauarcPath)
	local decoded = serde.decode("json", luaurcJson)

	if not decoded.aliases then
		decoded.aliases = {}
	end

	decoded.aliases.c = process.cwd

	local encoded = serde.encode("json", decoded, true)
	fs.writeFile(luauarcPath, encoded)
end

return generateAlias
