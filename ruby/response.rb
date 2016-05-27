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
    "HTTP/1.1 #{status} #{Utils::STATUS_CODES[status]}"
  end

  def headers
    {
      "Date" => Utils::date_imf,
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
