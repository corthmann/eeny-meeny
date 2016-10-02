module EenyMeeny
  class Variation
    attr_reader :id, :name, :weight, :options

    def initialize(id, name: '', weight: 1, **options)
      @id = id
      @name = name
      @weight = weight
      @options = options
    end
  end
end
