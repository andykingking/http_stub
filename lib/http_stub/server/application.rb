module HttpStub
  module Server

    class Application < Sinatra::Base

      register Sinatra::Partial

      enable :dump_errors, :logging, :partial_underscores

      def initialize
        super()
        @match_registry      = HttpStub::Server::Registry.new("match")
        @stub_registry       = HttpStub::Server::Stub::Registry.new(@match_registry)
        @scenario_registry   = HttpStub::Server::Registry.new("scenario")
        @stub_controller     = HttpStub::Server::Stub::Controller.new(@stub_registry)
        @scenario_controller = HttpStub::Server::Scenario::Controller.new(@scenario_registry, @stub_registry)
        @request_pipeline    =
          HttpStub::Server::RequestPipeline.new(@stub_controller, @scenario_controller, @match_registry)
      end

      private

      SUPPORTED_REQUEST_TYPES = [ :get, :post, :put, :delete, :patch, :options ].freeze

      def self.any_request_type(path, opts={}, &block)
        SUPPORTED_REQUEST_TYPES.each { |type| self.send(type, path, opts, &block) }
      end

      before do
        @response_pipeline = HttpStub::Server::ResponsePipeline.new(self)
        @http_stub_request = HttpStub::Server::Request.new(request)
      end

      public

      post "/http_stub/stubs" do
        response = @stub_controller.register(@http_stub_request, logger)
        @response_pipeline.process(response)
      end

      get "/http_stub/stubs" do
        haml :stubs, {}, stubs: @stub_registry.all
      end

      delete "/http_stub/stubs" do
        @stub_controller.clear(logger)
        halt 200, "OK"
      end

      post "/http_stub/stubs/memory" do
        @stub_registry.remember
        halt 200, "OK"
      end

      get "/http_stub/stubs/memory" do
        @stub_registry.recall
        halt 200, "OK"
      end

      get "/http_stub/stubs/matches" do
        haml :matches, {}, matches: @match_registry.all
      end

      get "/http_stub/scenarios/:name" do
        binding.pry
        haml :scenario, {}, scenario: @scenario_registry.find(params[:name], logger)
      end

      post "/http_stub/scenarios" do
        response = @scenario_controller.register(@http_stub_request, logger)
        @response_pipeline.process(response)
      end

      get "/http_stub/scenarios" do
        haml :scenarios, {}, scenarios: @scenario_registry.all.sort_by(&:uri)
      end

      delete "/http_stub/scenarios" do
        @scenario_controller.clear(logger)
        halt 200, "OK"
      end

      get "/http_stub/stubs/:id" do
        haml :stub, {}, the_stub: @stub_registry.find(params[:id], logger)
      end

      get "/application.css" do
        sass :application
      end

      get "/favicon.ico" do
        send_file File.expand_path("../views/favicon.ico", __FILE__)
      end

      any_request_type(//) do
        response = @request_pipeline.process(@http_stub_request, logger)
        @response_pipeline.process(response)
      end

      helpers do

        def h(text)
          Rack::Utils.escape_html(text)
        end

        def pretty_json(text)
          JSON.pretty_generate(JSON.parse(text))
        end

      end

    end

  end
end
