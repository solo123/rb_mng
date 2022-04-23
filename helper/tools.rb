module Ns
  module Helper
    def parse_json(str)
      JSON.parse(str)
    rescue JSON::ParserError
      {}
    end
  end
end