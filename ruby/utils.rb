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
      404 => 'Not Founder',
      505 => 'HTTP Version Not Supported'
    }

  LOGGER = Logger.new(STDOUT)
end
