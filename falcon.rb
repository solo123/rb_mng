#!/usr/bin/env -S falcon host
# frozen_string_literal: true

# Force to always use threads instead of processes/forks
Falcon::Command::Host.prepend(
  Module.new do
    def container_class
      Async::Container::Threaded
    end
  end
)

load :rack
#, :supervisor
#supervisor

#hostname = File.basename(__dir__)
rack 'hello.localhost' do
  endpoint do
    Async::HTTP::Endpoint.for('http', 'localhost', port: 3000, protocol: Async::HTTP::Protocol::HTTP1)
  end
end

=begin
rack hostname do
    endpoint ::Falcon::ProxyEndpoint.unix(
        '/tmp/falcon.sock',
        scheme: 'http',
        protocol: Async::HTTP::Protocol::HTTP1
    )
end
=end