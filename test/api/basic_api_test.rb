require './test/test_helper'
class BasicApiTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Mng::Route::App.app
  end

  def test_ping
    get '/ping'

    assert last_response.ok?
    assert_equal last_response.body, 'pong'
  end

  def test_export_csv
    post '/cms/merchant_summaries/export_by_platform?merchant_id=1001&type=month&year=2021&field=total_count'

    assert last_response.ok?
    #puts last_response.body
  end
  def test_export_plt_csv
    post '/cms/bill_summaries/export_by_platform?merchant_id=1001&type=month&year=2021&field=total_fee'

    assert last_response.ok?
    #puts last_response.body
  end
  def test_export_partner_csv
    post '/cms/bill_summaries/export_by_partner?merchant_id=1001&type=month&year=2021&field=total_fee'

    assert last_response.ok?
    #puts last_response.body
  end

  def test_get_statics_trades
    get '/statics/trades?page_size=3&last_id=6987&time_period=month'
    assert last_response.ok?
    #puts last_response.body
  end
end
