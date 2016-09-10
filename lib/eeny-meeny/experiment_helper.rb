require 'eeny-meeny/models/cookie'
require 'eeny-meeny/models/experiment'

module EenyMeeny::ExperimentHelper

  def participates_in?(experiment_id, variation_id: nil)
    experiment = EenyMeeny::Experiment.find_by_id(experiment_id)
    cookie = read_cookie(EenyMeeny::Cookie.cookie_name(experiment))
    cookie[:variation] unless cookie.nil? || (variation_id.present? && variation_id != cookie[:variation].id)
  end

  def smoke_test?(smoke_test_id, version: 1)
    cookie = read_cookie(EenyMeeny::Cookie.smoke_test_name(smoke_test_id, version: version))
    cookie[:variation] unless cookie.nil?
  end

  private

  def read_cookie(cookie_name)
    EenyMeeny::Cookie.read(cookies[cookie_name])
  end
end
