require 'eeny-meeny/shared_methods'

module EenyMeeny
  class RouteConstraint
    @@eeny_meeny_encryptor = nil

    def initialize(experiment_id, variation_id: nil)
      @experiment_id = experiment_id
      @variation_id = variation_id
      @version = experiment_version(experiment_id)
    end

    def matches?(request)
      !participates_in?(request).nil?
    end

    private

    def participates_in?(request)
      cookie = eeny_meeny_cookie(request)
      cookie[:variation] unless cookie.nil? || (!cookie.nil? && @variation_id.present? && @variation_id != cookie[:variation].id)
    end

    def eeny_meeny_cookie(request)
      cookie = request.cookie_jar[EenyMeeny::EENY_MEENY_COOKIE_PREFIX+@experiment_id.to_s+'_v'+@version.to_s]
      if cookie
        Marshal.load(decrypt(cookie)) rescue nil
      end
    end

    include EenyMeeny::SharedMethods
  end
end
