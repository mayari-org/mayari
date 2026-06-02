local Exception = {}

-- // BASE EXCEPTION FUNCTION // --

function Exception.HttpException(statusCode: number, message: string)
    return {
        statusCode = statusCode,
        message = message
    }
end

-- // COMMON 4xx // --

function Exception.BadRequest(message: string?)
    return Exception.HttpException(400, message or "Bad Request")
end

function Exception.Unauthorized(message: string?)
    return Exception.HttpException(401, message or "Unauthorized")
end

function Exception.Forbidden(message: string?)
    return Exception.HttpException(403, message or "Forbidden")
end

function Exception.NotFound(message: string?)
    return Exception.HttpException(404, message or "Not Found")
end

function Exception.Conflict(message: string?)
    return Exception.HttpException(409, message or "Conflict")
end

function Exception.TooManyRequests(message: string?)
    return Exception.HttpException(429, message or "Too Many Requests")
end

-- // COMMON 5xx // --

function Exception.InternalServerError(message: string?)
    return Exception.HttpException(500, message or "Internal Server Error")
end

function Exception.BadGateway(message: string?)
    return Exception.HttpException(502, message or "Bad Gateway")
end

function Exception.ServiceUnavailable(message: string?)
    return Exception.HttpException(503, message or "Service Unavailable")
end

return Exception
