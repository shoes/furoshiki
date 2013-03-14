module Furoshiki
  # Exception raised when there was a problem downloading a resource
  class DownloadError < StandardError; end

  # Exception raised when a configuration is invalid
  class ConfigurationError < StandardError; end
end
