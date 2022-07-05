module Errors
  class TamperingDetected < StandardError
    def message
      I18n.t('auth.tara.tampering')
    end
  end
end
