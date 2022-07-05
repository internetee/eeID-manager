require 'test_helper'

class OrderableTest < ActiveSupport::TestCase
  def test_order_model_by_desc
    desc = create_oderable_condition_for_user_model('desc')
    orderable_model = User.order(desc)

    assert_not_equal orderable_model.inspect, User.all.inspect

    orderable_model_manually = User.order(given_names: :desc)
    assert_equal orderable_model.inspect, orderable_model_manually.inspect
  end

  def test_order_model_by_asc
    asc = create_oderable_condition_for_user_model('asc')
    orderable_model = User.order(asc)

    assert_not_equal orderable_model.inspect, User.all.inspect

    orderable_model_manually = User.order(given_names: :asc)
    assert_equal orderable_model.inspect, orderable_model_manually.inspect
  end

  def test_order_not_orderable_model
    desc = Orderable.new(**{ model_name: 'Contact', column: 'name', direction: 'desc',
                             default: nil, nulls: 'LAST' }).condition

    non_orderable_model = Contact.order(desc)

    assert_equal non_orderable_model.inspect, Contact.all.inspect
  end

  def test_order_model_by_non_existing_column
    asc = Orderable.new(**{ model_name: 'User', column: 'address', direction: 'asc',
                            default: nil, nulls: 'LAST' }).condition
    orderable_model = User.order(asc)

    assert_equal orderable_model.inspect, User.all.inspect
  end

  def test_order_model_by_wrong_direction
    dir = create_oderable_condition_for_user_model('dir')
    orderable_model = User.order(dir)

    assert_equal orderable_model.inspect, User.all.inspect
  end

  def test_order_model_with_invalid_nulls
    desc = create_oderable_condition_for_user_model('desc', nil, 'SECOND')
    orderable_model = User.order(desc)

    assert_equal orderable_model.inspect, User.all.inspect
  end

  private

  def create_oderable_condition_for_user_model(direction, default = nil, nulls = 'LAST')
    Orderable.new(**{ model_name: 'User', column: 'given_names', direction: direction,
                      default: default,
                      nulls: nulls }).condition
  end
end
