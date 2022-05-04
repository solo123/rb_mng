require './test/test_helper'
class StaticSummaryTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Mng::Route::App.app
  end

  def test_static_summary
    post '/cms/bill_summaries/month_summary?merchant_id=3001&year=2021'

    assert last_response.ok?, last_response
    js = JSON.parse last_response.body
    assert_equal  0, js['code']
    assert js['data'].length > 0, js.to_json
  end
  def test_static_merchant_summary
    post '/cms/merchant_summaries/search_by_platform?merchant_id=1001&type=month&year=2021&field=total_count'

    assert last_response.ok?, last_response
    js = JSON.parse last_response.body
    assert_equal  0, js['code']
    assert js['data'].length > 0, js.to_json
  end
end
