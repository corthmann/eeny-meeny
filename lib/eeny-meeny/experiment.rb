require 'eeny-meeny/variation'

module EenyMeeny
  class Experiment
    attr_reader :id, :name, :version, :variations, :end_at, :start_at

    def initialize(id, name: '', version: 1, variations: [], start_at: nil, end_at: nil)
      @id = id
      @name = name
      @version = version
      @variations = variations.map do |variation_id, variation|
        Variation.new(variation_id, **variation)
      end
      @start_at = start_at
      @end_at = end_at

      #TODO: validate id is unique and variations are present
    end

    def pick_variation
      Hash[
          @variations.map do |variation|
            [variation, variation.weight]
          end
      ].max_by { |_, weight| rand ** (1.0 / weight) }.first
    end
  end
end
