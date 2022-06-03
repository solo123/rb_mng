module Mng
  module Route
    class App < Roda
      hash_branch("task") do |r|
        r.post('add'){
          if @t.include?(:task_type) && @t.include?(:creator)
            tsk = @t.dup
            tsk[:status] = 0
            tsk[:_id] = Ns::AutoIncId.get_next(:Jobs_MyTask)
            db = Mongoid.default_client.database
            db['jobs_my_tasks'].insert_one(tsk)
            r.halt 200, {code:0, msg: '成功添加任务', tsk: tsk}
          end
          r.halt 200, {code: 11, msg: '添加任务失败', params: @t}
        }
      end
    end
  end
end
