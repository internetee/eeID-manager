class BillingMailer < ApplicationMailer
  def account_credited(user, invoice)
    @user = user
    @invoice = invoice
    mail(to: user.email, subject: t('.subject'))
  end

  def out_of_balance(user)
    @user = user
    mail(to: user.email, subject: t('.subject'))
  end

  def balance_critical_level(user)
    @user = user
    @critical_level = Money.new(Setting.fetch(:billing, :balance_critical_cents), 'EUR')
    @left_authorizations = user.balance_cents / Setting.fetch(:billing, :auth_price)
    mail(to: user.email, subject: t('.subject'))
  end
end
