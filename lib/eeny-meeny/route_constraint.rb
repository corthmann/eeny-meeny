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
        Marshal.load(decrypt(cookie))
      end
    end

    def experiment_version(experiment_id)
      (Rails.application.config.eeny_meeny.experiments.
          try(:[], experiment_id.to_sym).try(:[], :version) || 1) rescue 1
    end

    def decrypt(cookie)
      begin
        if Rails.application.config.eeny_meeny.secure
          # Memoize encryptor to avoid creating new instances on every request.
          @@eeny_meeny_encryptor ||= EenyMeeny::Encryptor.new(Rails.application.config.eeny_meeny.secret)
          @@eeny_meeny_encryptor.decrypt(cookie)
        else
          cookie
        end
      rescue
        nil
      end
    end
  end
end
