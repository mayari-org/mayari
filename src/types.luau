-- TODO: Enhance the types

export type Next = () -> ResponsePayload

export type Nova = {
	--[[
        Starts the server
    ]]
	listen: (self: Nova, handler: () -> ()) -> (),
}

-- Middleware
export type Middleware = (req: Request | RequestWith<any>, next: Next) -> ResponsePayload?
export type Handler = (req: Request | RequestWith<any>) -> ResponsePayload?

-- Request
export type RequestWith<T> = {
	method: string,
	path: string,
	body: { any },
	headers: {
		[string]: string?,
	}?,
	params: T,
	query: T,
}

export type Request = RequestWith<{ [string]: any }>

-- Response
export type ResponseOptions = {
	status: number?,
	headers: { [string]: string }?,
}

export type ResponsePayload = {
	body: string,
	config: ResponseOptions,
}

export type Response = {
	--[[
        Respond with a string
    ]]
	send: (body: string, config: ResponseOptions?) -> ResponsePayload,

	--[[
        Respond with a json
    ]]
	json: <T>(body: T, config: ResponseOptions?) -> ResponsePayload,

	--[[
        Respond with an html
    ]]
	html: (body: string, config: ResponseOptions?) -> ResponsePayload,

	--[[
        Respond with a css
    ]]
	js: (body: string, config: ResponseOptions?) -> ResponsePayload,

	--[[
        Respond with a js
    ]]
	css: (body: string, config: ResponseOptions?) -> ResponsePayload,
}

-- Validators
export type BodyField = {
    type: string?,
    required: boolean?,
    min: number?,
    max: number?,
    pattern: string?,
}

export type StringField = {
    required: boolean?,
    minLength: number?,
    maxLength: number?,
    pattern: string?,
}

export type ValidatorSchema = {
    body: { [string]: BodyField }?,
    params: { [string]: StringField }?,
    query: { [string]: StringField }?,
}

return {}
