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

  private

  def create_oderable_condition_for_user_model(direction, default = nil, nulls = 'LAST')
    Orderable.new(**{model_name: 'User', column: 'given_names', direction: direction, default: default, nulls: nulls}).condition
  end
end
