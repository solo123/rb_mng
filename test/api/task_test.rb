require './test/test_helper'
class TaskTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Mng::Route::App.app
  end

  def test_add_task
    params = {
      title: 'test task01',
      task_type: 'Task::DummyTask',
      params: '3',
      creator: 'api',
    }
    post '/task/add', params.to_json
    assert last_response.ok?
    js = JSON.parse last_response.body
    puts js
  end


end
