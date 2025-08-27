class MockRackApp

  def initialize
    @request_headers = {}
  end

  def call(env)
    @env = env
    [200, {'Content-Type' => 'text/plain'}, ['OK']]
  end

  def [](key)
    @env[key]
  end
  alias_method :fetch, :[]

  def []=(key,value)
    @env[key] = value
  end
end
