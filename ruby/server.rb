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
  content = <<~EOT
    Method: #{request.method}
    Request-target: #{request.target}
    Headers: #{request.headers.pretty_inspect}
    Content: #{request.content}
  EOT
  TextResponse.new(content: content)
end

def serve_assets(asset_path)
  file_path = '.'  + asset_path
  raise FileNotFoundError if !File.exists?(file_path) or File.directory?(file_path)
  file = File.new(file_path)
  FileResponse.new(file: file)
end

def start
  server = TCPServer.new 2000 # Server bind to port 2000
  puts 'Now listening on port 2000'
  loop do
    client = server.accept    # Wait for a client to connect
    begin
      request = Request.from_socket(client)

      if request.method == 'HEAD'
        response = Response.new
      elsif request.target.start_with? '/assets'
        response = serve_assets(request.target)
      else
        response = echo_request(request)
      end

      response.to_socket(client)
    rescue HTTPVersionError
      Response.new(status: 505).to_socket(client)
    rescue RequestParseError
      Response.new(status: 400).to_socket(client)
    rescue FileNotFoundError
      Response.new(status: 404).to_socket(client)
    ensure
      client.close
    end
  end
end

if __FILE__ == $0 # this file's name equals the start file's name
  start
end
