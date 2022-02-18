class ServiceMailer < ApplicationMailer
  def service_created(service)
    addressee = service.user.email
    @user = service.user
    @service = service
    mail(to: addressee, subject: t('.subject', name: service.name))
  end

  def service_approved(service)
    addressee = service.user.email
    @user = service.user
    @service = service
    mail(to: addressee, subject: t('.subject', name: service.name))
  end

  def service_rejected(service)
    addressee = service.user.email
    @user = service.user
    @service = service
    mail(to: addressee, subject: t('.subject', name: service.name))
  end

  def notify_admins(service)
    admin_emails = User.admins.collect(&:email).join(",")
    @service = service
    mail(to: admin_emails, subject: t('.subject', name: service.name))
  end
end
