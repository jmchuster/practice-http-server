require 'socket'
require 'byebug'
require 'date'
require 'logger'
require 'pp'

$LOAD_PATH << File.dirname(__FILE__)
require 'request'
require 'response'
require 'utils'
require 'errors'

VALID_METHODS = ['GET', 'HEAD']

def echo_request(request)
  return Response.new if request.method == 'HEAD'

  content = <<~EOT
    Method: #{request.method}
    Request-target: #{request.target}
    Headers: #{request.headers.pretty_inspect}
    Content: #{request.content}
  EOT
  Response.new(content: content)
end

def start
  server = TCPServer.new 2000 # Server bind to port 2000
  puts 'Now listening on port 2000'
  loop do
    client = server.accept    # Wait for a client to connect
    begin
      request = Request.from_socket(client)
      response = echo_request(request)
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

if __FILE__ == $0 # this file's name equals the start file's name
  start
end
