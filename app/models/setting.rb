class Setting
  def self.fetch(*args)
    Rails.application.config.customization.dig(*args)
  end
end
