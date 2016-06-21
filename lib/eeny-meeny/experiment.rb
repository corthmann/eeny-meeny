require 'eeny-meeny/variation'
require 'active_support/core_ext/enumerable'

module EenyMeeny
  class Experiment
    attr_reader :id, :name, :version, :variations, :total_weight, :end_at, :start_at

    def initialize(id, name: '', version: 1, variations: {}, start_at: nil, end_at: nil)
      @id = id
      @name = name
      @version = version
      @variations = variations.map do |variation_id, variation|
        Variation.new(variation_id, **variation)
      end
      @total_weight = (@variations.empty? ? 1.0 : @variations.sum { |variation| variation.weight.to_f })

      @start_at = start_at
      @end_at = end_at
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
