import std.stdio;

import hunt.minihttp.HttpParser;
import hunt.minihttp.HttpMessage;
import hunt.minihttp.Define;

void main()
{
	string requestString = "GET / HTTP/1.1\r\nHost: example.com\r\nUser-Agent: Test Agent\r\nConnection: keep-alive\r\n\r\nHello world!";
	
	auto parser = new HttpParser;

	auto request = parser.Parse(requestString);

	writeln(request.ToString());
}
