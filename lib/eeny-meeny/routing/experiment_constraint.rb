require 'eeny-meeny/models/cookie'
require 'eeny-meeny/models/experiment'

module EenyMeeny
  class ExperimentConstraint

    def initialize(experiment_id, variation_id: nil)
      @experiment = EenyMeeny::Experiment.find_by_id(experiment_id)
      @variation_id = variation_id
    end

    def matches?(request)
      return false unless !@experiment.nil? && @experiment.active?
      participant_variation_id = EenyMeeny::Cookie.read(request.cookie_jar[EenyMeeny::Cookie.cookie_name(@experiment)])
      return false if participant_variation_id.nil? # Not participating in experiment
      (@variation_id.nil? || @variation_id == participant_variation_id)
    end
  end
end
