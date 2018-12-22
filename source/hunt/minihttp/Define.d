module hunt.minihttp.Define;

/**
    * HTTP defines that any lines must be seperated with a carriage return.
    * 
    * Define this as a constant to use across the library code and to change easily.
    */
enum CARRIAGE_RETURN = "\r\n";

/**
    * The string for HTTP version 1.0
    */
enum HTTP_VERSION_10 = "HTTP/1.0";

/**
    * The string for HTTP version 1.1
    */
enum HTTP_VERSION_11 = "HTTP/1.1";

/**
    * An enum of HTTP methods for use in a message.
    * 
    * Set to NONE for use in a response message, as responses do not use methods.
    */
enum HttpMethod : ushort
{
    NONE = 0,
    GET,
    HEAD,
    POST,
    PUT,
    DELETE,
    CONNECT,
    TRACE,
    PATCH
}

/**
    * Converts a HttpMethod enum to a string for use in a request.
    */
string httpMethodToString(HttpMethod method)
{
    switch (method)
    {
        case HttpMethod.NONE:
            return "NONE";
        case HttpMethod.GET:
            return "GET";
        case HttpMethod.HEAD:
            return "HEAD";
        case HttpMethod.POST:
            return "POST";
        case HttpMethod.PUT:
            return "PUT";
        case HttpMethod.DELETE:
            return "DELETE";
        case HttpMethod.CONNECT:
            return "CONNECT";
        case HttpMethod.TRACE:
            return "TRACE";
        case HttpMethod.PATCH:
            return "PATCH";
        default:
            return "UNKNOW";
    }
}

/**
    * Converts a string to a HttpMethod enum for use in a HttpMessage object.
    */
HttpMethod stringToHttpMethod(string method)
{
    if (method == "NONE")
        return HttpMethod.NONE;
    if (method == "GET")
        return HttpMethod.GET;
    if (method == "HEAD")
        return HttpMethod.HEAD;
    if (method == "POST")
        return HttpMethod.POST;
    if (method == "PUT")
        return HttpMethod.PUT;
    if (method == "DELETE")
        return HttpMethod.DELETE;
    if (method == "CONNECT")
        return HttpMethod.CONNECT;
    if (method == "TRACE")
        return HttpMethod.TRACE;
    if (method == "PATCH")
        return HttpMethod.PATCH;

    return HttpMethod.NONE;
}

/**
    * To be returned with a status code in a response is a status text describing the
    * status code by text rather than by a code.
    * 
    * This method takes in one of those codes and tries to return a text for it.
    */
string StatusTextFromStatusCode(short statusCode)
{
    switch (statusCode)
    {
    case 100:
        return "Continue";
    case 101:
        return "Switching Protocol";
    case 200:
        return "OK";
    case 201:
        return "Created";
    case 202:
        return "Accepted";
    case 203:
        return "Non-Authoritative Information";
    case 204:
        return "No Content";
    case 205:
        return "Reset Content";
    case 206:
        return "Partial Content";
    case 300:
        return "Multiple Choice";
    case 301:
        return "Moved Permanently";
    case 302:
        return "Found";
    case 303:
        return "See Other";
    case 304:
        return "Not Modified";
    // 305 is deprecated and 306 is only reserved, skip
    case 307:
        return "Temporary Redirect";
    case 308:
        return "Permanent Redirect";
    case 400:
        return "Bad Request";
    case 401:
        return "Unauthorized";
    case 402:
        // 402 is reserved for future use but has a status message, adding it
        return "Payment Required";
    case 403:
        return "Forbidden";
    case 404:
        return "Not Found";
    case 405:
        return "Method Not Allowed";
    case 406:
        return "Not Acceptable";
    case 407:
        return "Proxy Authentication Required";
    case 408:
        return "Request Timeout";
    case 409:
        return "Conflict";
    case 410:
        return "Gone";
    case 411:
        return "Length Required";
    case 412:
        return "Precondition Failed";
    case 413:
        return "Payload Too Large";
    case 414:
        return "URI Too Long";
    case 415:
        return "Unsupported Media Type";
    case 416:
        return "Requested Range Not Satisfiable";
    case 417:
        return "Expectation Failed";
    case 418:
        // might as well return the teapot joke
        return "I'm a teapot";
    case 421:
        return "Misdirected Request";
    case 425:
        return "Too Early";
    case 426:
        return "Upgrade Required";
    case 428:
        return "Precondition Required";
    case 429:
        return "Too Many Requests";
    case 431:
        return "Request Header Fields Too Large";
    case 451:
        return "Unavailable for Legal Reasons";
    case 500:
        return "Internal Server Error";
    case 501:
        return "Not Implemented";
    case 502:
        return "Bad Gateway";
    case 503:
        return "Service Unavailable";
    case 504:
        return "Gateway Timeout";
    case 505:
        return "HTTP Version Not Supported";
    case 506:
        return "Variant Also Negotiates";
    case 507:
        return "Insufficient Storage";
    case 510:
        return "Not Extended";
    case 511:
        return "Network Authentication Required";
    default:
        return "Undefined";
    }
}
