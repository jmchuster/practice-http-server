module Utils
  # all public helper functions in here
  module_function

  # e.g. Mon, 27 Jul 2009 12:28:53 GMT
  def date_imf
    Date.today.strftime('%a, %d %b %Y ') + Time.now.utc.strftime('%H:%M:%S GMT')
  end

  STATUS_CODES =
    {
      200 => 'OK',
      400 => 'Bad Request',
      404 => 'Not Found',
      505 => 'HTTP Version Not Supported'
    }

  LOGGER = Logger.new(STDOUT)

  MIME_TYPES = File.readlines('mime.types')
                  .select { |line| !(line[0].start_with?('#') || /\A[[:space:]]*\z/ === line) }
                  .map { |line| line.split }
                  .inject({}) { |memo, obj| obj[1..-1].each { |ext| memo[ext] = obj[0] }; memo }
end
