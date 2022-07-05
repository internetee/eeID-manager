class Service < ApplicationRecord
  include Concerns::Service::HydraConnectable
  belongs_to :user, optional: false
  belongs_to :contact
  has_many :authentications
  validates :name, :short_description, :approval_description,
            :callback_url, presence: true
  validate :validate_callback_url
  after_create :deliver_application_received_mail
  before_save :assign_password
  after_save :suspend_if_out_of_balance

  scope :unarchived, -> { where(archived: false) }

  def assign_password
    return if password.present?

    self.password = SecureRandom.hex(16)
  end

  def deliver_application_received_mail
    ServiceMailer.service_created(self).deliver_later
    ServiceMailer.notify_admins(self).deliver_later
  end

  def deliver_application_approved_mail
    ServiceMailer.service_approved(self).deliver_later
  end

  def deliver_application_rejected_mail
    ServiceMailer.service_rejected(self).deliver_later
  end

  def suspend!(no_credit: true)
    return if suspended? || !approved?

    suspend_hydra_client(no_credit)
    # TODO: inform user about suspension
    update(suspended: true)
  end

  def unsuspend!
    raise StandardError.new(message: 'User out of balance') if user.out_of_balance

    update_hydra_client
    update(suspended: false)
  end

  def suspend_if_out_of_balance
    suspend! if user.out_of_balance
  end

  def status
    return 'ARCHIVED' if archived?
    return 'REJECTED' if rejected?
    return 'AWAITING_APPROVAL' unless approved?
    return 'SUSPENDED' if suspended?

    'ACTIVE'
  end

  def archive!
    archive_hydra_client
    update(archived: true, client_id: nil)
  end

  def approve!
    bind_hydra_client
    update(approved: true, client_id: regex_service_name)
    deliver_application_approved_mail
  end

  def reject!
    delete_hydra_client
    update(client_id: nil, rejected: true, approved: false, suspended: false)
    deliver_application_rejected_mail
  end

  def disapprove!
    update(client_id: nil, rejected: false, approved: false, suspended: false)
    # TODO: inform customer here
  end

  def regex_service_name
    "oidc-#{user.uuid}-#{id}"
  end

  private

  def validate_callback_url
    uri = URI.parse(callback_url)
    return true if uri&.host

    errors.add(:callback_url, :invalid)
  rescue URI::InvalidURIError
    errors.add(:callback_url, :invalid)
  end
end
