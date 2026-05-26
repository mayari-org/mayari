local MAX_DECORATORS = 10

local function parseArgs(raw: string): { string }
	local args = {}
	for arg in raw:gmatch("([^,]+)") do
		local trimmed = arg:match("^%s*(.-)%s*$")
		if trimmed and trimmed ~= "" then
			table.insert(args, trimmed)
		end
	end
	return args
end

local function parseDecorator(line: string): { name: string, args: { string } }?
	local stripped = line:match("^%s*(.-)%s*$")

    if not stripped then
        return nil
    end

	if not (stripped:sub(1, 3) == "--@") then
		return nil
	end

	local body = stripped:match("^%-%-@(.+)$")
	if not body then
		return nil
	end

	local name = body:match("^([%w_]+)")
	if not name then
		return nil
	end

	local rawArgs = body:match("^[%w_]+%((.-)%)$") or ""

	return { name = name, args = parseArgs(rawArgs) }
end

local function isDecorator(line: string): boolean
	return line:match("^%-%-@[%w_]+%((.-)%)$") ~= nil
end

local function isFunction(line: string): boolean
	return line:match("^local%s+function%s+[%w_]+%s*%(") ~= nil
		or line:match("^function%s+[%w_%.]+%s*%(") ~= nil
		or line:match("^function%s+[%w_]+%s*:[%w_]+%s*%(") ~= nil
end

local function extractFunctionName(line: string): string?
	return line:match("^local%s+function%s+([%w_]+)%s*%(")
		or line:match("^function%s+([%w_%.]+)%s*%(")
		or line:match("^function%s+[%w_]+%s*:([%w_]+)%s*%(")
end

local function extractDecorator(source: string): { [string]: { string } }
	local results: { [string]: { string } } = {}
	local lines: { string } = {}

	for line in source:gmatch("[^\n]+") do
		local trimmed = nil
		if line then
			trimmed = line:match("^%s*(.-)%s*$") or ""
		else
			trimmed = ""
		end
		table.insert(lines, trimmed)
	end

	local i = 1
	while i <= #lines do
		local line = lines[i]

		if isDecorator(line) then
			local group: { string } = {}
			local j = i
			local maxReached = false

			while j <= #lines and isDecorator(lines[j]) do
				if #group >= MAX_DECORATORS then
					maxReached = true
					break
				end
				table.insert(group, lines[j])
				j += 1
			end

			if not maxReached and j <= #lines and isFunction(lines[j]) then
				local name = extractFunctionName(lines[j])
				if name then
					results[name] = group
				end
				i = j + 1
			else
				i = j
			end
		else
			i += 1
		end
	end

	return results
end

return {
    parseDecorator = parseDecorator,
    extractDecorator = extractDecorator,
}

-- --- TEST SCRIPT
-- local source = fs.open("./main.luau")
-- local open = fs.read(source)
-- fs.close(source)
-- local decorators = extractDecorators(open)

-- for i, v in decorators do
--     print(i .. ":")
--     for _, m in v do
--         print(m)
--         local decorators = parseDecorator(m)
--         if decorators then
--             print("  Decorator Name: " .. decorators.name)
--             print("  Arguments:")
--             for _, arg in decorators.args do
--                 print("    - " .. arg)
--             end
--         end
--     end
--     print()
-- end
