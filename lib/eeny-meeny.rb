require 'eeny-meeny/version'
require 'eeny-meeny/railtie' if defined?(Rails)
require 'eeny-meeny/models/encryptor'

module EenyMeeny

  class Config
    attr_accessor :cookies, :experiments, :secret, :secure

    attr_reader :encryptor

    def initialize
      @cookies     = { same_site: :strict, path: '/' }
      @experiments = {}
      @secret      = '9fc8b966eca7d03d55df40c01c10b8e02bf1f9d12d27b8968d53eb53e8c239902d00bf6afae5e726ce1111159eeb2f8f0e77233405db1d82dd71397f651a0a4f'
      @secure      = true
      @encryptor   = (@secure ? EenyMeeny::Encryptor.new(@secret) : nil)
    end
  end
  
  def self.config
    @@config ||= Config.new
  end

  def self.configure
    yield self.config
  end

  def self.reset!
    @@config = nil
  end

end
