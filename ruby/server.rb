require 'socket'
require 'byebug'
require 'date'

# e.g. Mon, 27 Jul 2009 12:28:53 GMT
def date
  Date.today.strftime('%a, %d %b %Y ') + Time.now.utc.strftime('%H:%M:%S GMT')
end

def start
  server = TCPServer.new 2000 # Server bind to port 2000
  puts 'Now listening on port 2000'
  loop do
    client = server.accept    # Wait for a client to connect
    response = <<~EOT
      HTTP/1.1 200 OK
      Date: #{date}
      Server: practice-http-server-ruby
      Content-Length: 2
      Content-Type: text/plain

      OK
    EOT
    response = response.gsub(/\n/, "\r\n")
    client.puts response
    client.close
  end
end

start
