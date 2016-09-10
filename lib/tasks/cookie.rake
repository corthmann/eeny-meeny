require 'rake'
require 'eeny-meeny/models/cookie'

def write_cookie(experiment_id, variation_id: nil)
  experiment = EenyMeeny::Experiment.find_by_id(experiment_id)
  raise "Experiment with id '#{experiment_id}' not found!" if experiment.nil?
  if variation_id.nil?
    EenyMeeny::Cookie.create_for_experiment(experiment, EenyMeeny.config.cookies)
  else
    EenyMeeny::Cookie.create_for_experiment_variation(experiment, variation_id, EenyMeeny.config.cookies)
  end
end

namespace :eeny_meeny do

  namespace :cookie do
    desc 'Generate a valid EenyMeeny experiment cookie'
    task :experiment, [:experiment_id] => :environment do |t, args|
      raise "Missing 'experiment_id' parameter" if (args['experiment_id'].nil? || args['experiment_id'].empty?)
      experiment_id = args['experiment_id'].to_sym
      cookie = write_cookie(experiment_id)
      puts cookie
    end

    desc 'Generate a valid EenyMeeny experiment cookie for a specific variation'
    task :experiment_variation, [:experiment_id, :variation_id] => :environment do |t, args|
      raise "Missing 'experiment_id' parameter" if (args['experiment_id'].nil? || args['experiment_id'].empty?)
      raise "Missing 'variation_id' parameter" if (args['variation_id'].nil? || args['variation_id'].empty?)
      experiment_id = args['experiment_id'].to_sym
      variation_id = args['variation_id'].to_sym
      cookie = write_cookie(experiment_id, variation_id: variation_id)
      puts cookie
    end
    #
    # desc 'Gemerate a valid EenyMeeny smoke test cookie'
    # task smoke_test: :environment do
    #   raise "Missing 'smoke_test_id'" if (ENV['smoke_test_id'].nil? || ENV['smoke_test_id'].empty?)
    # end
  end



end
