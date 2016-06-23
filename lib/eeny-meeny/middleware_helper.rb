module EenyMeeny::MiddlewareHelper
  def has_experiment_cookie?(cookies, experiment)
    cookies.has_key?(experiment_cookie_name(experiment))
  end

  def generate_cookie_value(experiment, cookie_config)
    variation = experiment.pick_variation
    cookie = {
        expires: (experiment.end_at || 1.year.from_now),
        httponly: true,
        value: Marshal.dump({
                                name: experiment.name,
                                variation: variation,
                            })
    }
    cookie[:same_site] = cookie_config[:same_site] unless cookie_config[:same_site].nil?
    cookie[:path] = cookie_config[:path] unless cookie_config[:path].nil?
    cookie
  end

  private
  def experiment_cookie_name(experiment)
    EenyMeeny::EENY_MEENY_COOKIE_PREFIX+experiment.id.to_s+'_v'+experiment.version.to_s
  end
end
