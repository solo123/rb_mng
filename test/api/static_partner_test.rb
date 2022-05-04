require './test/test_helper'
class StaticPartnerTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Mng::Route::App.app
  end

  def test_static_partner
    post '/cms/bill_summaries/search_by_partner?type=month&year=2021&field=merchant_count'

    assert last_response.ok?, last_response
    js = JSON.parse last_response.body
    assert_equal  0, js['code']
    assert js['data'].length > 0, js.to_json
  end
end
