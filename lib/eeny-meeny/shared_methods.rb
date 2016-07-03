module EenyMeeny::SharedMethods

  private

  def experiment_version(experiment_id)
    (Rails.application.config.eeny_meeny.experiments.
        try(:[], experiment_id.to_sym).try(:[], :version) || 1) rescue 1
  end

  def decrypt(cookie)
    begin
      if Rails.application.config.eeny_meeny.secure
        # Memoize encryptor to avoid creating new instances on every request.
        @@eeny_meeny_encryptor ||= EenyMeeny::Encryptor.new(Rails.application.config.eeny_meeny.secret)
        @@eeny_meeny_encryptor.decrypt(cookie)
      else
        cookie
      end
    rescue
      nil
    end
  end
end
