> We think that you'd benefit a lot from a little more experience on larger projects, and studying how the Internet works at a lower level. A good way to do this is to try writing a web server from scratch, using just a raw socket. Try to build a routing system into your server, and create some soft of dynamic website (using cookies). We'd be happy to give you feedback on this, after you've done it.

Entire spec http://httpwg.org/specs/

Message syntax and routing http://httpwg.org/specs/rfc7230.html

Semantics and content http://httpwg.org/specs/rfc7231.html

ELI5 https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol

e.g. client request

    GET /hello.txt HTTP/1.1
    User-Agent: curl/7.16.3 libcurl/7.16.3 OpenSSL/0.9.7l zlib/1.2.3
    Host: www.example.com
    Accept-Language: en, mi

server response

    HTTP/1.1 200 OK
    Date: Mon, 27 Jul 2009 12:28:53 GMT
    Server: Apache
    Last-Modified: Wed, 22 Jul 2009 19:15:56 GMT
    ETag: "34aa387-d-1568eb00"
    Accept-Ranges: bytes
    Content-Length: 51
    Vary: Accept-Encoding
    Content-Type: text/plain

    Hello World! My payload includes a trailing CRLF.

TODO:

[ ] Version 1
- read in request of type HEAD, GET
- echo
  - method
  - request-target in order-form
  - headers
  - content

[ ] Version 2
- parse request-target in order-form
  - map to local static assets
  - server up local static assets
  - respond with 404 if not found
- graceful close
  - https://www.safaribooksonline.com/library/view/http-the-definitive/1565925092/ch04s07.html
  - on receive of `Connection: close` header from client
    - close server write
    - wait up to 5 seconds for close of client write
    - close server read
  - close connection after 30 seconds of no requests

[ ] Version 3
- read in request of type POST
- map /assets to local static assets
- map /posts/:id to a local method
- read and write cookies as session state
