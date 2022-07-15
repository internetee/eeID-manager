class Feature
  def self.billing_system_integration_enabled?
    EidManager::Application.config
                           .customization[:billing_system_integration]
                           &.compact&.fetch(:enabled, false)
  end
end
