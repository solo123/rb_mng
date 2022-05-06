require './test/test_helper'
class StaticApiTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Mng::Route::App.app
  end

  def test_get_merchant_directory
    post '/cms/merchants/next_tenants?merchant_id=1001'

    assert last_response.ok?, last_response
    js = JSON.parse last_response.body
    assert_equal  0, js['code']
    assert js['data'].length > 0, js.to_json
  end
  def test_get_all_merchant_directory
    post('/cms/merchants/next_tenants?merchant_id=1001', {status: 5}.to_json, { 'CONTENT_TYPE' => 'application/json' })
    assert last_response.ok?, last_response
    js = JSON.parse last_response.body
    assert_equal  0, js['code']
    assert js['data'].length > 0, js.to_json
  end

  def test_static_by_platform
    uri = '/cms/bill_summaries/search_by_platform?field=total_fee&type=day&month=202101&ns_dbg=1'
    json = {search_type: "trade_type", value: "payment"}.to_json
    post(uri, json, { 'CONTENT_TYPE' => 'application/json' })

    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal  0, js['code']
    assert js['data'] && js['data'].include?('data') && js['data'].include?('summary')

    dt1 = js['data']['data'].first
    assert dt1.is_a?(Hash), "wrong data type: #{dt1.class}"
    assert dt1.include?("2021-01-01")
    assert_equal 600, dt1["2021-01-01"]
    assert dt1['merchant_id']
    assert dt1['total'] > 0
    assert dt1.include?('name')

    sm = js['data']['summary']
    assert sm.is_a?(Hash)
    assert 2400, sm["2021-01-01"]
    assert sm.keys.length>0
  end
  def test_static_by_platform_month
    uri = '/cms/bill_summaries/search_by_platform?field=total_fee&type=month&year=2021&ns_dbg=1'
    json = {search_type: "trade_type", value: "payment"}.to_json
    post(uri, json, { 'CONTENT_TYPE' => 'application/json' })

    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal  0, js['code']
    assert js['data'] && js['data'].include?('data') && js['data'].include?('summary')

    dt1 = js['data']['data'].first
    assert dt1.is_a?(Hash), "wrong data type: #{dt1.class}"
    assert dt1.include?("2021-01")
    assert_equal 600, dt1["2021-01"]
    assert dt1['merchant_id']
    assert dt1['total'] > 0
    assert dt1.include?('name')

    sm = js['data']['summary']
    assert sm.is_a?(Hash)
    assert 2400, sm["2021-01"]
    assert sm.keys.length>0
  end

  def test_static_by_platform_month_cnt
    uri = '/cms/bill_summaries/search_by_platform?field=order_count&type=month&year=2021&ns_dbg=1'
    json = {search_type: "trade_type", value: "payment"}.to_json
    post(uri, json, { 'CONTENT_TYPE' => 'application/json' })

    assert last_response.ok?
    js = JSON.parse last_response.body
    assert_equal  0, js['code']
    assert js['data'] && js['data'].include?('data') && js['data'].include?('summary')

    dt1 = js['data']['data'].first
    assert dt1.is_a?(Hash), "wrong data type: #{dt1.class}"
    assert dt1.include?("2021-01")
    assert_equal 60, dt1["2021-01"]
    assert dt1['merchant_id']
    assert dt1['total'] > 0
    assert dt1.include?('name')

    sm = js['data']['summary']
    assert sm.is_a?(Hash)
    assert 24, sm["2021-01"]
    assert sm.keys.length>0
  end

  def test_static_by_platform_bijun_all
    uri = '/cms/bill_summaries/search_by_platform?merchant_id=3001&field=bijun&type=month&year=2021&ns_dbg=1'
    json = {search_type: "all", value: nil}.to_json
    post(uri, json, { 'CONTENT_TYPE' => 'application/json' })

    assert last_response.ok?
    js = JSON.parse last_response.body
    #puts js
    assert_equal  0, js['code']
    assert js['data'] && js['data'].include?('data') && js['data'].include?('summary')

    dt1 = js['data']['data'].first
    assert dt1.is_a?(Hash), "wrong data type: #{dt1.class}"
    assert dt1.include?("2021-01")
    assert_equal 10, dt1["2021-01"]
    assert dt1['merchant_id']
    assert_equal 10, dt1['total']
    assert dt1.include?('name')

    sm = js['data']['summary']
    assert sm.is_a?(Hash)
    assert 10, sm["2021-01"]
    assert sm.keys.length == 12
  end
  def test_static_by_platform_bijun
    uri = '/cms/bill_summaries/search_by_platform?merchant_id=3001&field=bijun&type=month&year=2021&ns_dbg=1'
    json = {search_type: "trade_type", value: "payment"}.to_json
    post(uri, json, { 'CONTENT_TYPE' => 'application/json' })

    assert last_response.ok?
    js = JSON.parse last_response.body
    #puts js
    assert_equal  0, js['code']
    assert js['data'] && js['data'].include?('data') && js['data'].include?('summary')

    dt1 = js['data']['data'].first
    assert dt1.is_a?(Hash), "wrong data type: #{dt1.class}"
    assert dt1.include?("2021-01")
    assert_equal 10, dt1["2021-01"]
    assert dt1['merchant_id']
    assert_equal 10, dt1['total']
    assert dt1.include?('name')

    sm = js['data']['summary']
    assert sm.is_a?(Hash)
    assert 10, sm["2021-01"]
    assert sm.keys.length == 12
  end
  def test_static_by_platform_shanghujun
    uri = '/cms/bill_summaries/search_by_platform?merchant_id=3001&tab=shanghujun&type=month&year=2021&ns_dbg=1'
    json = {search_type: "trade_type", value: "payment"}.to_json
    post(uri, json, { 'CONTENT_TYPE' => 'application/json' })

    assert last_response.ok?
    js = JSON.parse last_response.body
    #puts js
    assert_equal  0, js['code']
    assert js['data'] && js['data'].include?('data') && js['data'].include?('summary')

    dt1 = js['data']['data'].first
    assert dt1.is_a?(Hash), "wrong data type: #{dt1.class}"
    assert dt1.include?("2021-01")
    assert_equal 6, dt1["2021-01"]
    assert dt1['merchant_id']
    assert_equal 6, dt1['total']
    assert dt1.include?('name')

    sm = js['data']['summary']
    assert sm.is_a?(Hash)
    assert 6, sm["2021-01"]
    assert sm.keys.length == 12
  end
  def test_static_by_platform_shanghujun_all
    uri = '/cms/bill_summaries/search_by_platform?merchant_id=3001&tab=shanghujun&type=month&year=2021&ns_dbg=1'
    json = {search_type: "all", value: nil}.to_json
    post(uri, json, { 'CONTENT_TYPE' => 'application/json' })

    assert last_response.ok?
    js = JSON.parse last_response.body
    #puts js
    assert_equal  0, js['code']
    assert js['data'] && js['data'].include?('data') && js['data'].include?('summary')

    dt1 = js['data']['data'].first
    assert dt1.is_a?(Hash), "wrong data type: #{dt1.class}"
    assert dt1.include?("2021-01")
    assert_equal 12, dt1["2021-01"]
    assert dt1['merchant_id']
    assert_equal 12, dt1['total']
    assert dt1.include?('name')

    sm = js['data']['summary']
    assert sm.is_a?(Hash)
    assert 12, sm["2021-01"]
    assert sm.keys.length == 12
  end
end