class Request
  attr_accessor :method
  attr_accessor :target
  attr_accessor :headers
  attr_accessor :content

  def initialize(method:, target:, headers: {}, content: '')
    @method = method
    @target = target
    @headers = headers || {}
    @content = content || ''
  end

  # http://httpwg.org/specs/rfc7230.html#rule.token.separators
  # def split_header_value(value_str)
  #   token = Regexp.escape("!#$%&'*+-.^_`|~") + '0-9A-Za-z'
  #   dquoted = /.*?[^\\]/.source
  #   value_str.scan(/"(#{dquoted})"|([#{token}]+)/).flatten.compact
  # end

  def self.from_socket(socket)
    request_line = socket.gets
    method, target, http_version = request_line.split
    raise HTTPVersionError if http_version != 'HTTP/1.1'
    raise RequestParseError if !VALID_METHODS.include?(method)

    headers = {}
    while request_line = socket.gets and request_line != "\r\n"
      key, value = request_line.split(':', 2)

      previous_headers = headers[key.upcase]
      if previous_headers
        headers[key.upcase] = [*previous_headers] << value.strip
      else
        headers[key.upcase] = value.strip
      end
    end

    content = ''
    if headers['CONTENT-LENGTH']
      content = socket.read(headers['CONTENT-LENGTH'])
    end

    request = Request.new(
      method: method,
      target: target,
      headers: headers,
      content: content
    )

    Utils::LOGGER.info request.pretty_inspect

    request
  rescue => e
    LOGGER.error e
    raise RequestParseError
  end

end
