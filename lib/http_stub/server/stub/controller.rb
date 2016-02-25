module HttpStub
  module Server
    module Stub

      class Controller

        def initialize(registry)
          @registry = registry
        end

        def register(request, logger)
          stub = HttpStub::Server::Stub.create(HttpStub::Server::Stub::Parser.parse(request))
          @registry.add(stub, logger)
          HttpStub::Server::Response.success("location" => stub.stub_uri)
        end

        def replay(request, logger)
          stub = @registry.find(request, logger)
          stub ? stub.response : HttpStub::Server::Response::NOT_FOUND
        end

        def clear(logger)
          @registry.clear(logger)
        end

      end

    end
  end
end
