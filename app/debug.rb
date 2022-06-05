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
            cnd = {_id: {:$gt=> to_object_id(model_name, last_id)}}
          else
            cnd = {}
          end
          db[model_name].find(cnd).limit(page_size.to_i).as_json
        }
        r.post('p', String){ |model_name|
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
            cnd = (@t[:q] || {}).merge({_id: {:$gt=> to_object_id(model_name, last_id)}})
          else
            cnd = @t[:q] || {}
          end
          if @t[:sort]
            ord = @t[:sort]
          else
            ord = {}
          end
          db[model_name].find(cnd).sort(ord).limit(page_size.to_i).as_json
        }
        r.post('p', String, 'count'){ |model_name|
          db = Mongoid.default_client.database
          if model_name == 'list'
            r.halt 200, {code: 0, data: db.collection_names}
          end
          unless db.collection_names.include?(model_name)
            r.halt 200, {code: 12, msg: "数据表(#{model_name})不存在"}
          end
          last_id = r.params["last_id"]
          if last_id
            cnd = (@t[:q] || {}).merge({_id: {:$gt=> to_object_id(model_name, last_id)}})
          else
            cnd = @t[:q] || {}
          end
          cnt = db[model_name].find(cnd).count()
          {code: 0, count: cnt}
        }
        r.get('p', String, 'count'){ |model_name|
          db = Mongoid.default_client.database
          unless db.collection_names.include?(model_name)
            r.halt 200, {code: 12, msg: "数据表(#{model_name})不存在"}
          end
          cnt = db[model_name].count
          {code: 0, count: cnt}
        }
        r.get('p', String, String){ |model_name, mid|
          db = Mongoid.default_client.database
          unless db.collection_names.include?(model_name)
            r.halt 200, {code: 12, msg: "数据表(#{model_name})不存在"}
          end
          rec = db[model_name].find({_id: to_object_id(model_name, mid)}).first
          if rec
            rec.as_json
          else
            r.halt 200, {code: 1, msg: "ID: #{mid} table: #{model_name} not found!"}
          end
        }

      end
    end
  end
end
