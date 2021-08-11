require 'active_support/concern'
require 'eeny-meeny/models/cookie'
require 'eeny-meeny/models/experiment'

module EenyMeeny::ExperimentHelper
  extend ActiveSupport::Concern

  included do
    helper_method :participates_in?, :smoke_test?
  end

  def participates_in?(experiment_id, variation_id: nil)
    experiment = EenyMeeny::Experiment.find_by_id(experiment_id)
    return unless !experiment.nil? && experiment.active?
    participant_variation_id = read_cookie(EenyMeeny::Cookie.cookie_name(experiment))
    return if variation_id && variation_id.to_s != participant_variation_id
    experiment.find_variation(participant_variation_id)
  end

  def smoke_test?(smoke_test_id, version: 1)
    cookie = read_cookie(EenyMeeny::Cookie.smoke_test_name(smoke_test_id, version: version))
    cookie unless cookie.nil?
  end

  private

  def read_cookie(cookie_name)
    EenyMeeny::Cookie.read(cookies[cookie_name])
  end
end
