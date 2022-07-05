require 'identity_code'
require 'countries'
class User < ApplicationRecord
  CUSTOMER_ROLE = 'customer'.freeze
  ADMINISTRATOR_ROLE = 'administrator'.freeze
  ROLES = %w[administrator customer].freeze
  ESTONIAN_COUNTRY_CODE = 'EE'.freeze
  TARA_PROVIDER = 'tara'.freeze

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable,
         :timeoutable

  alias_attribute :country_code, :alpha_two_country_code

  scope :admins, -> { where(roles: ['administrator']) }

  validates :identity_code, uniqueness: { scope: :alpha_two_country_code }, allow_blank: true
  validate :identity_code_must_be_valid_for_estonia, if: proc { |user|
    user.country_code.present? && user.identity_code.present?
  }

  validates :given_names, :surname, safe_value: true
  validates :given_names, :surname, presence: true
  validates :billing_recipient, :billing_street, :billing_city,
            :billing_zip, :billing_alpha_two_country_code, presence: true
  validate :customer_must_accept_terms_and_conditions
  has_many :payment_orders, dependent: :nullify
  has_many :invoices, dependent: :nullify
  has_many :services, dependent: :destroy
  has_many :authentications, through: :services
  has_many :transactions, dependent: :destroy
  has_many :contacts, dependent: :destroy

  def suspend_services!(no_credit: true)
    services.each { |s| s.suspend!(no_credit: no_credit) }

    BillingMailer.out_of_balance(self).deliver_later if no_credit
  end

  def admin?
    role?(ADMINISTRATOR_ROLE)
  end

  def balance_critical!
    BillingMailer.balance_critical_level(self).deliver_later
  end

  def out_of_balance
    balance_cents < 9
  end

  def unsuspend_services!
    services.where(approved: true, suspended: true).each(&:unsuspend!)
  end

  def vat_rate
    return Countries.vat_rate_from_alpha2_code(country_code) if country_code == 'EE'
    return BigDecimal('0') if billing_vat_code.present?

    Countries.vat_rate_from_alpha2_code(country_code)
  end

  def identity_code_must_be_valid_for_estonia
    return if IdentityCode.new(country_code, identity_code).valid?

    errors.add(:identity_code, I18n.t(:is_invalid))
  end

  def customer_must_accept_terms_and_conditions
    return if terms_and_conditions_accepted_at.present?

    errors.add(:terms_and_conditions, I18n.t('users.must_accept_terms_and_conditions'))
  end

  def accepts_terms_and_conditions=(acceptance)
    acceptance_as_bool = ActiveRecord::Type::Boolean.new.cast(acceptance)
    new_terms_and_conditions_accepted_at = if acceptance_as_bool
                                             terms_and_conditions_accepted_at || Time.now.utc
                                           end
    self.terms_and_conditions_accepted_at = new_terms_and_conditions_accepted_at
  end

  def accepts_terms_and_conditions
    terms_and_conditions_accepted_at.present?
  end

  def display_name
    "#{given_names} #{surname}"
  end

  def role?(role)
    roles.include?(role)
  end

  def deletable?
    invoices&.issued&.blank?
  end

  def signed_in_with_identity_document?
    provider == TARA_PROVIDER && uid.present?
  end

  def requires_captcha?
    !signed_in_with_identity_document?
  end

  # Make sure that notifications are send asynchronously
  def send_devise_notification(notification, *args)
    I18n.with_locale(locale) do
      devise_mailer.send(notification, self, *args).deliver_later
    end
  end

  def tampered_with?(omniauth_hash)
    uid_from_hash = omniauth_hash['uid']
    provider_from_hash = omniauth_hash['provider']

    begin
      uid != uid_from_hash ||
        provider != provider_from_hash ||
        country_code != uid_from_hash.slice(0..1) ||
        identity_code != uid_from_hash.slice(2..-1) ||
        given_names != omniauth_hash.dig('info', 'first_name') ||
        surname != omniauth_hash.dig('info', 'last_name')
    end
  end

  def self.from_omniauth(omniauth_hash)
    uid = omniauth_hash['uid']
    provider = omniauth_hash['provider']

    User.find_or_initialize_by(provider: provider, uid: uid) do |user|
      user.given_names = omniauth_hash.dig('info', 'first_name')
      user.surname = omniauth_hash.dig('info', 'last_name')
      if provider == TARA_PROVIDER
        user.country_code = uid.slice(0..1)
        user.identity_code = uid.slice(2..-1)
      end
    end
  end
end
