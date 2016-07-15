module HttpStub
  module Server
    module Request

      class Request

        attr_reader :uri, :method, :headers, :parameters, :body

        def initialize(rack_request)
          @uri        = rack_request.path_info
          @method     = rack_request.request_method.downcase
          @headers    = HttpStub::Server::Request::Headers.create(rack_request)
          @parameters = HttpStub::Server::Request::Parameters.create(rack_request)
          @body       = rack_request.body.read
        end

      end

    end
  end
end