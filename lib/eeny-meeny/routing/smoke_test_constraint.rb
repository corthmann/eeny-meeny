require 'eeny-meeny/models/cookie'

module EenyMeeny
  class SmokeTestConstraint

    def initialize(smoke_test_id, version: 1)
      @smoke_test_cookie_name = EenyMeeny::Cookie.smoke_test_name(smoke_test_id, version: version)
    end

    def matches?(request)
      cookie = EenyMeeny::Cookie.read(request.cookie_jar[@smoke_test_cookie_name])
      !cookie.nil?
    end
  end
end
