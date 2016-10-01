require 'rack'

module EenyMeeny
  class Cookie
    COOKIE_PREFIX = 'eeny_meeny_'.freeze
    SMOKE_TEST_PREFIX = 'smoke_test_'.freeze

    attr_accessor :value
    attr_reader :name, :expires, :httponly, :same_site, :path

    def self.create_for_experiment_variation(experiment, variation_id, config = {})
      variation = experiment.variations.detect { |v| v.id == variation_id }
      raise "Variation '#{variation_id}' not found for Experiment '#{experiment.id}'" if variation.nil?
      options = {
          name: cookie_name(experiment),
          value: Marshal.dump({
                                  name: experiment.name,
                                  variation: variation
                              })
      }
      options[:expires] = experiment.end_at if experiment.end_at
      if EenyMeeny.config.secure
        options[:value] = EenyMeeny.config.encryptor.encrypt(options[:value])
      end
      new(**options.merge(config))
    end

    def self.create_for_experiment(experiment, config = {})
      options = {
          name: cookie_name(experiment),
          value: Marshal.dump({
                                  name: experiment.name,
                                  variation: experiment.pick_variation
                              })
      }
      options[:expires] = experiment.end_at if experiment.end_at
      if EenyMeeny.config.secure
        options[:value] = EenyMeeny.config.encryptor.encrypt(options[:value])
      end
      new(**options.merge(config))
    end

    def self.create_for_smoke_test(smoke_test_id, version: 1, **config)
      options = {
          name: smoke_test_name(smoke_test_id, version: version),
          value: Marshal.dump({
                                  name: smoke_test_id,
                                  version: version
                              })
      }
      if EenyMeeny.config.secure
        options[:value] = EenyMeeny.config.encryptor.encrypt(options[:value])
      end
      new(**options.merge(config))
    end

    def self.smoke_test_name(smoke_test_id, version: 1)
      return if smoke_test_id.nil?
      SMOKE_TEST_PREFIX+smoke_test_id.to_s+'_v'+version.to_s
    end

    def self.cookie_name(experiment)
      return if experiment.nil?
      COOKIE_PREFIX+experiment.id.to_s+'_v'+experiment.version.to_s
    end

    def self.read(cookie_string)
      return if cookie_string.nil? || cookie_string.empty?
      begin
        return Marshal.load(cookie_string) unless EenyMeeny.config.secure # Cookie encryption disabled.
        Marshal.load(EenyMeeny.config.encryptor.decrypt(cookie_string))
      rescue
        nil # Return nil if cookie is invalid.
      end
    end

    def initialize(name: '', value: '', expires: 1.month.from_now, http_only: true, same_site: nil, path: nil)
      @name      = name
      @expires   = expires
      @httponly  = http_only
      @value     = value
      @same_site = same_site
      @path      = path
    end

    def to_h
      hash = {
          expires: @expires,
          httponly: @httponly,
          value: @value
      }
      hash[:same_site] = @same_site unless @same_site.nil?
      hash[:path] = @path unless @path.nil?
      hash
    end

    def to_s
      header = {}
      Rack::Utils.set_cookie_header!(header, name, to_h)
      header['Set-Cookie']
    end

  end
end
