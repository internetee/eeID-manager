require 'test_helper'

class DirectoResponseTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:customer)

    @invoice = invoices(:payable)
    @response_xml = "<?xml version='1.0' encoding='UTF-8'?><results><Result Type='0' Desc='OK' docid='#{@invoice.number}' doctype='ARVE' submit='Invoices'/></results>"
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
    Spy.on(Feature, :billing_system_integration_enabled?).and_return(true)
  end

  def test_should_update_related_invoice
    directo_response_from_billing = {
      response: @response_xml,
    }

    refute @invoice.in_directo

    params = JSON.parse(directo_response_from_billing.to_json)
    put eis_billing_directo_response_path, params: params,
                                           headers: { 'HTTP_COOKIE' => 'session=customer' }

    @invoice.reload
    assert @invoice.in_directo
  end
end
