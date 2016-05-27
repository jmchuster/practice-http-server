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

  def initialize(status: 200)
    @status = status
  end

  def status_line
    "HTTP/1.1 #{status} #{Utils::STATUS_CODES[status]}"
  end

  def content_length
    0
  end

  def headers
    {
      "Date" => Utils::date_imf,
      "Server" => "practice-http-server-ruby",
      "Content-Length" => content_length
    }
  end

  def to_socket(socket)
    socket.puts status_line +
                "\r\n" +
                headers.each.map { |key, value| "#{key}: #{value}\r\n" }.join +
                "\r\n"
  end
end

class TextResponse < Response
  def initialize(status: 200, content_type: nil, content:)
    super(status: status)
    @content_type = content_type ||  'text/plain'
    @content = content
  end

  def content_length
    content.length
  end

  def headers
    super.merge({ "Content-Type" => content_type })
  end

  def to_socket(socket)
    super
    socket.puts content
  end
end

class FileResponse < Response
  def initialize(status: 200, content_type: nil, file:)
    super(status: status)
    @content_type = Utils::MIME_TYPES[File.extname(file)[1..-1]] || 'application/octet-stream'
    @file = file
  end

  def content_length
    @file.size
  end

  def headers
    super.merge({ "Content-Type" => content_type })
  end

  def to_socket(socket)
    super
    IO.copy_stream(@file, socket, content_length)
  end
end
