class Authentication < ApplicationRecord
  belongs_to :service, optional: false
  validates :session_id, :principal_code, :first_name, :last_name, :channel, presence: true
  after_create :create_paid_transaction

  def create_paid_transaction
    transaction = Transaction.new
    transaction.user = service.user
    transaction.authentication = self
    transaction.save
  end

  def self.process(log)
    session_data = log['tara.session']
    return unless Authentication.processable?(session_data)

    auth = Authentication.find_or_initialize_by(session_id: session_data['sessionId'])
    auth_params = Authentication.context_from_log(session_data['authenticationResult'])
    auth.service = Service.unarchived.find_by(client_id: session_data['loginRequestInfo']['clientId'])
    auth.first_name = auth_params['first_name']
    auth.last_name = auth_params['last_name']
    auth.principal_code = auth_params['principal_code']
    auth.channel = auth_params['channel']

    auth.save
  end

  def self.processable?(data)
    data['state'] == 'AUTHENTICATION_SUCCESS'
  end

  def self.context_from_log(data)
    { channel: data['amr'],
      last_name: data['lastName'],
      first_name: data['firstName'],
      principal_code: data['subject'] }.as_json
  end
end
