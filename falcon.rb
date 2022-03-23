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

load :rack, :supervisor
supervisor

hostname = File.basename(__dir__)
rack 'hello.localhost' do
  endpoint do
    Async::HTTP::Endpoint.for('http', 'localhost', port:3000, protocol: Async::HTTP::Protocol::HTTP1)
  end
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
