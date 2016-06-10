module EenyMeeny
  class Variation
    attr_reader :id, :name, :weight, :options

    def initialize(id, name: '', weight: 1, **options)
      @id = id
      @name = name
      @weight = weight
      @options = options
    end

    def marshal_dump
      [@id, { name: @name, weight: @weight, **@options }]
    end

    def marshal_load(array)
      send :initialize, array[0], **array[1]
    end
  end
end
