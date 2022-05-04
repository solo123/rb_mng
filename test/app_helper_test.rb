require './test/test_helper'

class AppHelperTest < MiniTest::Test
  include Mng::Helper::RouteHelper

  def test_get_root_mch
    m = get_merchant_by_id(nil)
    assert m
    assert_equal'1001', m.id
    puts "merchant root: #{m.id}"
  end
end