require "cubscout/version"
require "cubscout/config"

require "cubscout/resource"
require "cubscout/request"
require "cubscout/response"

require "cubscout/scopes"
require "cubscout/list"
require "cubscout/object"
require "cubscout/conversation"
require "cubscout/user"
require "cubscout/thread_item"

module Cubscout
  class Error < StandardError; end

  class AuthenticationError < Error; end
  class InternalError < Error; end
  class InvalidFormatError < Error; end
  class JsonParseError < Error; end
  class MalformedRequestError < Error; end
  class PermissionDeniedError < Error; end
  class ResourceNotFoundError < Error; end
  class RateLimitExceeded < Error; end

  class ParameterMissing < Error; end
end
