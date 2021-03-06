module HttpStub
  module Server
    module Scenario

      class Parser

        def self.parse(request)
          JSON.parse(request.parameters["payload"]).tap do |payload|
            payload["stubs"].each { |stub_payload| HttpStub::Server::Stub::Payload.modify!(stub_payload, request) }
          end
        end

      end

    end
  end
end
