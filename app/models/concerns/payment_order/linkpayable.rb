# frozen_string_literal: true

module Concerns
  module PaymentOrder
    module Linkpayable
      extend ActiveSupport::Concern
      CONFIG_NAMESPACE = 'psd2'

      USER = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :user)

      KEY = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :key)

      LINKPAY_PREFIX = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :linkpay_prefix)

      LINKPAY_CHECK_PREFIX = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :linkpay_check_prefix)

      LINKPAY_TOKEN = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :linkpay_token)

      TRUSTED_DATA = 'trusted_data'

      def linkpay_url
        return if paid?

        linkpay_url_builder
      end

      def linkpay_url_builder
        total = invoices.map(&:cents).sum * (1 + user.vat_rate)
        money = Money.new(total, 'EUR')
        price = money&.format(symbol: nil, thousands_separator: false, decimal_mark: '.')
        data = linkpay_params(price).to_query

        hmac = OpenSSL::HMAC.hexdigest('sha256', KEY, data)
        "#{LINKPAY_PREFIX}?#{data}&hmac=#{hmac}"
      end

      def linkpay_params(price)
        { 'transaction_amount' => price.to_s,
          'order_reference' => uuid,
          'customer_name' => user.given_names.parameterize(separator: '_', preserve_case: true),
          'customer_email' => user.email,
          'custom_field_1' => '',
          'linkpay_token' => LINKPAY_TOKEN }
      end
    end
  end
end
