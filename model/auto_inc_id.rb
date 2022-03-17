module Ns
  class AutoIncId
    include Mongoid::MyDbTools

    field :_id, type: String
    field :next, type: Integer, default: 0

    class << self
      def get_next(id_name) # 'Collection_class_name'
        where(id: id_name.to_s).find_one_and_update({ :$inc => { next: 1 } }, :upsert => true, :return_document => :after)[:next]
      end

      def get_curr(id_name) # 'Collection_class_name'
        find_or_create_by(id: id_name.to_s)[:next]
      end

      def get_next_by_date(id_name)
        k = Time.current.to_ymd_str
        i = get_next(id_name.to_s + k)
        format("%s%04d", k, i)
      end

      def set_start(hash = {})
        hash.each do |k, v|
          where(id: k.to_s).find_one_and_update({ :$set => { next: v.to_i } }, :upsert => true)
        end
      end

      def reset(*keys)
        t = keys.map { |e| e.to_s }
        self.in(id: t).set next: 0
      end
    end
  end
end
