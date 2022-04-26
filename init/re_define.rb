module BSON
  class ObjectId
    alias :to_json :to_s
    alias :as_json :to_s
  end
end

class Hash
  def flatten_to_root
    self.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        v.flatten_to_root.map do |h_k, h_v|
          h["#{k}.#{h_k}"] = h_v
        end
      else 
        h[k] = v
      end
    end
  end
end