module HttpStub
  module Configurer
    module Request

      class StubResponse

        def initialize(id, args)
          @id               = id
          @status           = args[:status] || ""
          @headers          = (args[:headers] || {}).with_indifferent_and_insensitive_access
          @body             = args.has_key?(:json) ? args[:json].to_json : args[:body]
          @delay_in_seconds = args[:delay_in_seconds] || ""
        end

        def payload
          { status: @status, headers: @headers, body: @body, delay_in_seconds: @delay_in_seconds }
        end

        def file
          contains_file? ? create_response_file : nil
        end

        private

        def contains_file?
          @body.is_a?(Hash) && @body.key?(:file)
        end

        def create_response_file
          args = { id: @id, type: @headers["content-type"] }.merge(@body[:file])
          HttpStub::Configurer::Request::StubResponseFile.new(args)
        end

      end

    end
  end
end
