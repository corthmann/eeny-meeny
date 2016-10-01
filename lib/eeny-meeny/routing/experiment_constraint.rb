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
      cookie = EenyMeeny::Cookie.read(request.cookie_jar[EenyMeeny::Cookie.cookie_name(@experiment)])
      return false if cookie.nil? # Not participating in experiment
      (@variation_id.nil? || @variation_id == cookie[:variation].id)
    end
  end
end
