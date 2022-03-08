# frozen_string_literal: true

module Invoice::BookKeeping
  extend ActiveSupport::Concern

  def as_directo_json
    invoice = ActiveSupport::JSON.decode(ActiveSupport::JSON.encode(self))
    invoice['customer'] = compose_directo_customer
    invoice['issue_date'] = issue_date.strftime('%Y-%m-%d')
    invoice['transaction_date'] = paid_at&.strftime('%Y-%m-%d')
    invoice['language'] = user.locale
    invoice['invoice_lines'] = compose_directo_product

    invoice
  end

  def compose_directo_product
    [{ 'product_id': 'ETTEM06', 'description': "Order nr. #{number}",
       'quantity': 1, 'price': ActionController::Base.helpers.number_with_precision(
         price.to_s, precision: 2, separator: '.'
       ) }].as_json
  end

  def compose_directo_customer
    {
      'code': '',
      'destination': user.billing_alpha_two_country_code,
      'vat_reg_no': user.billing_vat_code
    }.as_json
  end
end
