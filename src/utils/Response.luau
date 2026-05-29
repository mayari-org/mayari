local Types = require("../types")
local serde = require("@adpt/serde")

local Response = {} :: Types.Response

local encode = serde.encode

local function generateResponse(body: string, config: Types.ResponseOptions)
	return {
		body = body,
		config = {
			status = config.status,
			headers = config.headers,
		},
	}
end

function Response.send(body: string, config: Types.ResponseOptions?)
	return generateResponse(tostring(body), {
		status = if config and config.status then config.status else 200,
		headers = if config and config.headers
			then config.headers
			else {
				["Content-Type"] = "text/plain",
			},
	})
end

function Response.json<T>(body: T, config: Types.ResponseOptions?)
	local encodedBody = encode("json", body)

	return generateResponse(encodedBody, {
		status = if config and config.status then config.status else 200,
		headers = if config and config.headers
			then config.headers
			else {
				["Content-Type"] = "application/json",
			},
	})
end

function Response.html(body: string, config: Types.ResponseOptions?)
	return generateResponse(tostring(body), {
		status = if config and config.status then config.status else 200,
		headers = if config and config.headers
			then config.headers
			else {
				["Content-Type"] = "text/html",
			},
	})
end

function Response.css(body: string, config: Types.ResponseOptions?)
        return generateResponse(tostring(body), {
		status = if config and config.status then config.status else 200,
		headers = if config and config.headers
			then config.headers
			else {
				["Content-Type"] = "text/css",
			},
	})
end

function Response.js(body: string, config: Types.ResponseOptions?)
	return generateResponse(tostring(body), {
		status = if config and config.status then config.status else 200,
		headers = if config and config.headers
			then config.headers
			else {
				["Content-Type"] = "text/javascript",
			},
	})
end

return Response
