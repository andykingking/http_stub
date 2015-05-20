module HttpStub
  module Configurer
    module Request
      module Http

        class Multipart

          def initialize(path, model)
            @path = path
            @model = model
          end

          def to_http_request
            Net::HTTP::Post::Multipart.new(@path, parameters)
          end

          private

          def parameters
            { payload: @model.payload.to_json }.tap do |parameters|
              @model.response_files.each do |response_file|
                parameters["response_file_#{response_file.id}"] =
                  UploadIO.new(response_file.path, response_file.type, response_file.name)
              end
            end
          end

        end

      end
    end
  end
end