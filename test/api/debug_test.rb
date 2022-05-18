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
  def test_get_table_data1
    get '/debug/p/ns_refunds?page_size=2&last_id=61c6757001c91160e9c7e71d'
    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal 0, js['code']
    #puts js
  end
  def test_get_table_data2
    #TODO: haveto use post body. cannot pass int params.
    get '/debug/p/ns_merchants?page_size=2&last_id=2001&q[role_id]=5'
    assert last_response.ok?
    js = JSON.parse last_response.body
    #puts js
  end
  def test_get_table_list
    get '/debug/p/list'
    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal 0, js['code']
    #puts js
  end
  def test_get_table_by_id
    get '/debug/p/ns_refunds/61c6757001c91160e9c7e71d'
    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal 0, js['code']

    get '/debug/p/ns_merchants/3001'
    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal 0, js['code']
    #puts js
  end

end
