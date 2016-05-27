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

class Request
  attr_accessor :method
  attr_accessor :target
  attr_accessor :headers
  attr_accessor :content
end

def build_request(socket)
  Request.new
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
  attr_accessor :status
  attr_accessor :content
  attr_accessor :content_type

  def initialize(status: 200, content_type: 'text/plain', content: '')
    @status = status
    @content_type = content_type
    @content = content
  end

  def status_line
    "HTTP/1.1 #{status} #{status_codes[status]}"
  end

  def headers
    {
      "Date" => date_imf,
      "Server" => "practice-http-server-ruby",
      "Content-Length" => content.length,
      "Content-Type" => content_type
    }
  end

  def to_string
    status_line +
      "\r\n" +
      headers.each.map { |key, value| "#{key}: #{value}\r\n" }.join +
      "\r\n" +
      content
  end
end

def handle_request(request)
  content = <<~EOT
    Method: #{request.method}
    Request-target: #{request.target}
    Headers: #{request.headers}
    Content: #{request.content}
  EOT
  Response.new(content: content)
end

class HTTPVersionError < StandardError
end

class RequestParseError < StandardError
end

def start
  server = TCPServer.new 2000 # Server bind to port 2000
  puts 'Now listening on port 2000'
  loop do
    client = server.accept    # Wait for a client to connect
    begin
      request = build_request(client)
      response = handle_request(request)
      client.puts response.to_string
    rescue HTTPVersionError
      client.puts Response.new(status: 505).to_string
    rescue RequestParseError
      client.puts Response.new(status: 400).to_string
    ensure
      client.close
    end
  end
end

start
