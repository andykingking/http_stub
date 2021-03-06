module HttpStub
  module Server
    module Application

      class Application < Sinatra::Base

        register Sinatra::Namespace
        register Sinatra::Partial

        set :root, File.expand_path("../..", __FILE__)
        set :environment, :test
        set :session_identifier, nil

        enable  :dump_errors, :logging, :partial_underscores
        disable :protection, :cross_origin_support

        def self.configure(args)
          configuration = HttpStub::Server::Application::Configuration.new(args)
          configuration.settings.each { |name, value| set(name, value) }
        end

        def initialize
          @session_configuration = HttpStub::Server::Session::Configuration.new(settings.session_identifier)
          @server_memory         = HttpStub::Server::Memory::Memory.new(@session_configuration)
          super()
        end

        include HttpStub::Server::Application::RequestSupport
        include HttpStub::Server::Application::ResponseSupport

        register HttpStub::Server::Application::CrossOriginSupport

        include HttpStub::Server::Application::Routes::Resource
        include HttpStub::Server::Application::Routes::Status
        include HttpStub::Server::Application::Routes::Memory
        include HttpStub::Server::Application::Routes::Scenario
        include HttpStub::Server::Application::Routes::Session
        include HttpStub::Server::Application::Routes::Stub

        helpers HttpStub::Server::Application::SessionUriSupport
        helpers HttpStub::Server::Application::TextFormattingSupport

      end

    end
  end
end
