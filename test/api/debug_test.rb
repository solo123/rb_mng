require './test/test_helper'
class DebugTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Mng::Route::App.app
  end

  def test_get_table_data_err
    get '/debug/p/abcde'
    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal 12, js['code']
  end
  def test_get_table_data
    get '/debug/p/ns_merchants'
    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal 0, js['code']
    #puts js
  end
  def test_get_table_list
    get '/debug/p/list'
    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal 0, js['code']
    puts js
  end

end
