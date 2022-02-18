class Contact < ApplicationRecord
  has_many :services
  belongs_to :user

  scope :default, -> { where(default: true) }
  scope :main, -> { where(main: true) }

  validates :name, :email, :identity_code, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def destroy_enabled?
    services.unarchived.empty?
  end

  def service_list
    services.pluck(:name)
  end
end
