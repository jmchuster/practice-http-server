require 'socket'
require 'byebug'
require 'date'
require 'logger'
require 'pp'

VALID_METHODS = ['GET', 'HEAD']

LOGGER = Logger.new(STDOUT)

def status_codes
  {
    200 => 'OK',
    400 => 'Bad Request',
    404 => 'Not Founder',
    505 => 'HTTP Version Not Supported'
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

  def initialize(method:, target:, headers: {}, content: '')
    @method = method
    @target = target
    @headers = headers
    @content = content
  end

end

# http://httpwg.org/specs/rfc7230.html#rule.token.separators
def split_header_value(value_str)
  token = Regexp.escape("!#$%&'*+-.^_`|~") + '0-9A-Za-z'
  dquoted = /.*?[^\\]/.source
  value_str.scan(/"(#{dquoted})"|([#{token}]+)/).flatten.compact
end

def build_request(socket)
  begin
    request_line = socket.gets
    method, target, http_version = request_line.split
    raise HTTPVersionError if http_version != 'HTTP/1.1'
    raise RequestParseError if !VALID_METHODS.include?(method)

    headers = {}
    byebug
    while request_line = socket.gets and request_line != "\r\n"
      key, value_str = request_line.split(':', 2)
      headers[key.upcase] ||= []
      headers[key.upcase].concat(split_header_value(value_str))
    end

    if headers['CONTENT-LENGTH']
      content = socket.read(headers['CONTENT-LENGTH'])
    end

    Request.new(
      method: method,
      target: target,
      headers: headers,
      content: content
    )
  rescue => e
    LOGGER.error e
    raise RequestParseError
  end
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
  return Response.new if request.method == 'HEAD'

  content = <<~EOT
    Method: #{request.method}
    Request-target: #{request.target}
    Headers: #{request.headers.pretty_inspect}
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
