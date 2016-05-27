require 'socket'
require 'byebug'
require 'date'

def status_codes
  {
    200 => 'OK'
  }
end

# e.g. Mon, 27 Jul 2009 12:28:53 GMT
def date_imf
  Date.today.strftime('%a, %d %b %Y ') + Time.now.utc.strftime('%H:%M:%S GMT')
end

def build_request(client)
end

# e.g.
# HTTP/1.1 200 OK
# Date: Mon, 27 Jul 2009 12:28:53 GMT
# Server: practice-http-server-ruby
# Content-Length: 2
# Content-Type: text/plain
#
# OK
class Response
  def status_line
    "HTTP/1.1 #{status} #{status_codes[status]}"
  end

  def status
    200
  end

  def headers
    {
      "Date" => date_imf,
      "Server" => "practice-http-server-ruby",
      "Content-Length" => content.length,
      "Content-Type" => "text/plain"
    }
  end

  def content
    'OK'
  end

  def handle(request)
    # do something with the request
    build_response
  end

  def build_response
    status_line +
      "\r\n" +
      headers.each.map { |key, value| "#{key}: #{value}\r\n" }.join +
      "\r\n" +
      content
  end
end

def start
  server = TCPServer.new 2000 # Server bind to port 2000
  puts 'Now listening on port 2000'
  loop do
    # tpsocket
    client = server.accept    # Wait for a client to connect
    request = build_request(client)
    response = Response.new.handle(request)
    client.puts response
    client.close
  end
end

start
