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
    post '/cms/merchant_summaries/export_by_platform'

    assert last_response.ok?
    puts last_response.body
  end
end
