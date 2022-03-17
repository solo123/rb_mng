#!/usr/bin/env -S falcon host
# frozen_string_literal: true

# Force to always use threads instead of processes/forks
module Falcon
  module Command
    class Host
      def container_class
        Async::Container::Threaded
      end
    end
  end
end

load :rack

hostname = File.basename(__dir__)
rack hostname do
  endpoint Async::HTTP::Endpoint.parse("http://localhost:3000").with(protocol: Async::HTTP::Protocol::HTTP1)
end

#supervisor

=begin
rack hostname do
    endpoint ::Falcon::ProxyEndpoint.unix(
        ::File.expand_path('tmp/sockets/falcon', root),
        scheme: 'http',
        protocol: Async::HTTP::Protocol::HTTP1
    )
end
=end
