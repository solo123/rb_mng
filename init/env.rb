module Ns
    CurrEnv = (ENV.fetch 'APP_ENV', 'development').downcase
end
module BSON
    class ObjectId
      alias :to_json :to_s
      alias :as_json :to_s
    end
  end