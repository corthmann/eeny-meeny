module EenyMeeny::MiddlewareHelper
  def has_experiment_cookie?(cookies, experiment)
    cookies.has_key?(experiment_cookie_name(experiment))
  end

  def generate_cookie_value(experiment)
    variation = experiment.pick_variation
    {
        same_site: :strict,
        expires: (experiment.end_at || 1.year.from_now),
        value: Marshal.dump({
                                name: experiment.name,
                                variation: variation,
                            })
    }
  end

  private
  def experiment_cookie_name(experiment)
    EenyMeeny::EENY_MEENY_COOKIE_PREFIX+experiment.id.to_s
  end
end
