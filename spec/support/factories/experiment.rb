# frozen_string_literal: true

require 'eeny-meeny/models/experiment'

def build_experiment(id: :experiment_1, **options)
  experiment_options = {
    name: 'Test 1',
    variations: {
      a: { name: 'A' },
      b: { name: 'B' }}
  }.merge(options)
  EenyMeeny::Experiment.new(id, **experiment_options)
end
