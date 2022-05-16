module Mng
  module Route
    class App < Roda
      hash_branch("debug") do |r|
        r.get('p', String){ |model_name|
          db = Mongoid.default_client.database
          if model_name == 'list'
            r.halt 200, {code: 0, data: db.collection_names}
          end
          unless db.collection_names.include?(model_name)
            r.halt 200, {code: 12, msg: "数据表(#{model_name})不存在"}
          end
          page_size = r.params["page_size"] || 100
          last_id = r.params["last_id"]
          if last_id
            cnd = @t.merge({_id: {:$gt=> last_id.to_s}})
          else
            cnd = @t
          end
          db[model_name].find(cnd).limit(page_size.to_i).as_json
        }

      end
    end
  end
end
