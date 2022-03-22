module Codes
  module Tools

    class RemoteAgent
      attr_accessor :agents
      def initialize
        @agents = {}
        @count = 0
      end
      def agent_code(agent_name)
        code = @agents[agent_name]
        unless code
          @count += 1
          @agents[agent_name] = code = @count
        end
        "%05d" % code
      end
    end
  end
end