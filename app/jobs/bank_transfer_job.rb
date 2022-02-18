class BankTransferJob < ApplicationJob
  def perform
    configure_lhv_keystore
    configure_lhv_connector
    @billing_account_iban = sepa_params[:billing_account_iban]

    incoming_transactions = fetch_incoming_transactions
    (log('No incoming transactions') and return) unless incoming_transactions.any?

    incoming_transactions.each { |transaction| process_transaction(transaction) }
    log("Transactions processed: #{incoming_transactions.size}")
  end

  def process_transaction(transaction)
    user = User.find_by(uuid: transaction.description.strip!)
    return unless user

    create_and_pay_topup_invoice(user, Money.from_amount(transaction.amount, 'EUR').cents)
    log("Credited account #{user.uuid} with #{invoice.price}EUR")
  end

  def create_and_pay_topup_invoice(user, cents)
    invoice = Invoice.by_top_up_request(user: user, cents: cents, psd2: false)
    invoice.save

    payment_order = PaymentOrder.new_from_invoice(invoice, psd2: false)
    payment_order.save

    payment_order.mark_invoice_as_paid
  end

  def log(msg)
    @log ||= Logger.new(STDOUT)
    @log.info("[BankTransferJob] #{msg}")
  end

  def fetch_incoming_transactions
    incoming_transactions = []
    @connector.credit_debit_notification_messages.each do |message|
      next unless message.bank_account_iban == @billing_account_iban

      message.credit_transactions.each do |credit_transaction|
        incoming_transactions << credit_transaction
      end
    end

    incoming_transactions
  end

  def configure_lhv_connector
    @connector = Lhv::ConnectApi.new
    @connector.cert = @keystore.certificate
    @connector.key = @keystore.key
    @connector.ca_file = sepa_params[:lhv_ca_file]
    @connector.dev_mode = sepa_params[:lhv_dev_mode] == 'true'
  end

  def configure_lhv_keystore
    @keystore = OpenSSL::PKCS12.new(File.read(sepa_params[:lhv_p12_keystore]),
                                    sepa_params[:lhv_keystore_password])
  end

  def sepa_params
    Rails.application.config.customization.dig(:payment_methods, :sepa)
  end
end
