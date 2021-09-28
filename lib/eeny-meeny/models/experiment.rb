require 'eeny-meeny/models/cookie'
require 'eeny-meeny/models/variation'
require 'active_support/time'
require 'active_support/core_ext/enumerable'

module EenyMeeny
  class Experiment

    COOKIE_EXPERIMENT_ID_REGEX = Regexp.new(
      "\\A#{EenyMeeny::Cookie::EXPERIMENT_PREFIX}(.+)_v(\\d+)\\z"
    ).freeze

    attr_reader :id,
                :name,
                :version,
                :variations,
                :total_weight,
                :smoke_test_dependency,
                :end_at,
                :start_at

    def self.find_all
      return [] unless EenyMeeny.config.experiments
      EenyMeeny.config.experiments.map do |id, experiment|
        new(id, **experiment)
      end
    end

    def self.find_by_id(experiment_id)
      return unless EenyMeeny.config.experiments
      experiment = EenyMeeny.config.experiments[experiment_id.to_sym]
      new(experiment_id, **experiment) if experiment
    end

    def self.find_by_cookie_name(cookie_name)
      return unless cookie_name =~ COOKIE_EXPERIMENT_ID_REGEX

      experiment = find_by_id($1)
      return unless experiment && experiment.version.to_s == $2

      experiment
    end

    def initialize(id, name: '', version: 1, variations: {}, smoke_test_dependency: nil, start_at: nil, end_at: nil)
      @id = id
      @name = name
      @version = version
      @smoke_test_dependency = smoke_test_dependency
      @variations = variations.map do |variation_id, variation|
        Variation.new(variation_id, **variation)
      end
      @total_weight = (@variations.empty? ? 1.0 : @variations.sum { |variation| variation.weight.to_f })
      @start_at = Time.zone.parse(start_at) if start_at
      @end_at = Time.zone.parse(end_at) if end_at
    end

    def active?(now = Time.zone.now)
      return true if @start_at.nil? && @end_at.nil?
      return true if @end_at.nil? && (@start_at && (now > @start_at)) # specified start - open-ended
      return true if @start_at.nil? && (@end_at && (now < @end_at)) # unspecified start - specified end
      !!((@start_at && (now > @start_at)) && (@end_at && (now < @end_at))) # specified start and end
    end

    def find_variation(variation_id)
      @variations.detect { |v| v.id.to_s == variation_id.to_s }
    end

    def pick_variation
      Hash[
          @variations.map do |variation|
            [variation, variation.weight]
          end
      ].max_by { |_, weight| rand ** (@total_weight / weight) }.first
    end
  end
end
