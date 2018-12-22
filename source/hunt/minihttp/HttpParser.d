module hunt.minihttp.HttpParser;

import hunt.minihttp.Define;
import hunt.minihttp.HttpMessage;

import std.conv : to;

/**
    * A basic class to parse a HTTP message, both request and response.
    * 
    * Allows for either string data to be passed in, or for a vector of
    * unsigned 8-bit integers to be passed in.
    * 
    * Requires that a whole message be sent in for parsing.
    */
class HttpParser
{
    /**
        * An enum of states that the HttpParser can be in.
        */
    enum MessageParserState : ushort
    {
        NONE,
        PARSING_START_LINE,
        START_LINE_REQUEST,
        START_LINE_RESPONSE,
        HEADER_KEY,
        HEADER_VALUE,
        PARSING_BODY,
    }

    /**
        * Parse a string to a HTTP message.
        * 
        * Pass in a pointer to an HttpMessage which is then written to for headers
        * and other message data.
        * 
        * note: this must be a complete HTTP message
        */
    HttpMessage Parse(string buffer)
    {
        return Parse(cast(ubyte[])buffer.dup);
    }
    
    /**
        * Parse a binary vector to an HTTP message.
        * 
        * Pass in a pointer to an HttpMessage which is written to for headers and
        * other message data.
        * 
        * note: shrink the vector buffer before passing it in with `shrink_to_fit`
        * otherwise empty characters will show up for the body
        * note: must be a complete HTTP message.
        */
    HttpMessage Parse(ubyte[] buffer)
    {
        // begin by parsing the start line without knowing if it is a
        // request or a response by setting as undetermined
        MessageParserState state = MessageParserState.PARSING_START_LINE;
    
        // a temporary string instance used for storing characters of a
        // current line in the message being parsed
        string temp = "";

        // whether to skip the next character (for a carriage return)
        bool skipNext = false;

        // the current key for a header
        string headerKey = "";

        // whether or not a message body is present
        bool hasMessageBody = false;

        // the index at which the message body begins
        size_t bodyStartIndex = 0;

        auto httpMessage = new HttpMessage;

        for (size_t index = 0; index < buffer.length; index++)
        {
            ushort character = buffer[index];

            // skip this character as it was marked
            if (skipNext)
            {
                skipNext = false;

                continue;
            }

            // if we are parsing the body, then we only need to grab an index and break
            // out of this loop as we want to merely insert the data from this vector
            // into the body vector
            if (state == MessageParserState.PARSING_BODY)
            {
                hasMessageBody = true;

                bodyStartIndex = index;

                break;
            }

            // if we are parsing the start line but neither a response or request
            if (state == MessageParserState.PARSING_START_LINE)
            {
                // if we hit a space, we have to check if the start line begins
                // with the HTTP version or the method verb
                if (character == ' ')
                {
                    // this message has a leading version string, thus it is
                    // a response and not a request
                    if (temp == HTTP_VERSION_10 || temp == HTTP_VERSION_11)
                    {
                        httpMessage.SetMethod(HttpMethod.NONE);

                        state = MessageParserState.START_LINE_RESPONSE;

                        temp = "";

                        continue;
                    }
                    // this must be a request, so grab the HttpMethod type
                    // for the request, set it, and move on
                    else
                    {
                        httpMessage.SetMethod(stringToHttpMethod(temp));

                        state = MessageParserState.START_LINE_REQUEST;
                    
                        temp = "";

                        continue;
                    }
                }
            }
            // do actions for when the start line is a request
            else if (state == MessageParserState.START_LINE_REQUEST)
            {
                // once a space is hit, add the path to the message
                if (character == ' ')
                {
                    httpMessage.SetPath(temp);

                    temp = "";

                    continue;
                }
                // when the beginning of a carriage return is hit, add the version string
                // to the message and then skip the following new line character, setting
                // the state of the parser to be parsing headers
                else if (character == '\r')
                {
                    httpMessage.SetVersion(temp);

                    temp = "";

                    state = MessageParserState.HEADER_KEY;

                    skipNext = true;

                    continue;
                }
            }
            // do actions for when the start line is a response
            else if (state == MessageParserState.START_LINE_RESPONSE)
            {
                // if we are at a space, then we have hit the status code for the response
                if (character == ' ')
                {
                    short code = temp.to!short;
                    
                    httpMessage.SetStatusCode(code);

                    temp = "";

                    continue;
                }
                // if we are at a carriage return start, then set the status message for
                // the response, this can be blank in which it will use a generated status
                //
                // this will also set the state of the parser to move on to headers
                else if (character == '\r')
                {
                    httpMessage.SetStatusMessage(temp);

                    temp = "";

                    state = MessageParserState.HEADER_KEY;

                    skipNext = true;

                    continue;
                }
            }
            // if we are parsing header keys and hit a colon, then the key for the header has
            // been fully parsed and should be added to the temporary key holder
            else if (state == MessageParserState.HEADER_KEY && character == ':')
            {
                headerKey = temp;

                temp = "";

                state = MessageParserState.HEADER_VALUE;

                // HTTP defines that the next character in a header should be a space
                // so skip that for parsing the value of the header
                skipNext = true;

                continue;
            }
            // if we are parsing header values and hit the beginning of a carriage return then
            // it is time to add the header to the message with the key and value, and move the
            // state back to parsing keys
            else if (state == MessageParserState.HEADER_VALUE && character == '\r')
            {
                httpMessage.SetHeader(headerKey, temp);

                headerKey = "";
                temp      = "";

                state = MessageParserState.HEADER_KEY;

                // skip the next character as it will just be a newline
                skipNext = true;

                continue;
            }
            // if we are parsing header keys and we hit a carriage return, then we should assume
            // that the headers have ended, and that we are now parsing a message body.
            else if (state == MessageParserState.HEADER_KEY && character == '\r')
            {
                temp = "";

                state = MessageParserState.PARSING_BODY;

                // skip the next character as it'll be a newline
                skipNext = true;

                continue;
            }

            temp ~= character;
        }

        // add the body to the message if it is present
        if (hasMessageBody)
            httpMessage.SetMessageBody(buffer[bodyStartIndex..buffer.length]);

        return httpMessage;
    }
}
