require 'eeny-meeny/shared_methods'

module EenyMeeny::ExperimentHelper
  @@eeny_meeny_encryptor = nil

  def participates_in?(experiment_id, variation_id: nil)
    cookie = eeny_meeny_cookie(experiment_id)
    cookie[:variation] unless cookie.nil? || (variation_id.present? && variation_id != cookie[:variation].id)
  end

  private

  def eeny_meeny_cookie(experiment_id)
    cookie = cookies[EenyMeeny::EENY_MEENY_COOKIE_PREFIX+experiment_id.to_s+'_v'+experiment_version(experiment_id).to_s]
    if cookie
      Marshal.load(decrypt(cookie)) rescue nil
    end
  end

  include EenyMeeny::SharedMethods
end
