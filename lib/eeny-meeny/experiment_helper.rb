module EenyMeeny::ExperimentHelper
  @@eeny_meeny_encryptor = nil

  def participates_in?(experiment_id, variation_id: nil, version: 1)
    cookie = eeny_meeny_cookie(experiment_id, version: version)
    cookie[:variation] unless cookie.nil? || (variation_id.present? && variation_id != cookie[:variation].id)
  end

  private

  def eeny_meeny_cookie(experiment_id, version: 1)
    cookie = cookies[EenyMeeny::EENY_MEENY_COOKIE_PREFIX+experiment_id.to_s+'_v'+version.to_s]
    if cookie
      Marshal.load(decrypt(cookie))
    end
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
