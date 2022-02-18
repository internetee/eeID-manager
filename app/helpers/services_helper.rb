module ServicesHelper
  def default_contact(contact, current_user)
    return [contact.name, contact.id] if contact

    default_contact = current_user.contacts.default.first || current_user.contacts.main.first
    [default_contact&.name, default_contact&.id]
  end

  def auth_methods(service)
    return %w[idcard mid smartid] unless service.persisted?

    service.auth_methods
  end

  def environment(service)
    return %w[Test] unless service.persisted?

    service.environment
  end
end
