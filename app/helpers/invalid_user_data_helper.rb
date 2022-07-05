module InvalidUserDataHelper
  def set_invalid_data_flag_in_session
    return unless current_user

    session['user.invalid_user_data'] = user_data_invalid?
  end

  def invalid_data_banner
    return unless session['user.invalid_user_data']

    content_tag(:div, class: 'ui message ban') do
      content_tag(:div, t('users.invalid_user_data'), class: 'header')
    end
  end

  private

  def user_data_invalid?
    keys = %i[given_names surname mobile_phone billing_recipient billing_street billing_city
              billing_zip billing_alpha_two_country_code customer_must_accept_terms_and_conditions
              identity_code]
    current_user.invalid? &&
      current_user.errors.attribute_names.any? { |key| keys.include?(key) }
  end
end
