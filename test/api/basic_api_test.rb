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
    puts last_response.body
  end
end
