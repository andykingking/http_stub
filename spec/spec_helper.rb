require 'bundler'
Bundler.require(:development)

SimpleCov.start do
  coverage_dir "tmp/coverage"

  add_filter "/spec/"
  add_filter "/vendor/"

  minimum_coverage 99.55
  refuse_coverage_drop
end if ENV["coverage"]

require 'http_server_manager/test_support'

require_relative '../lib/http_stub/rake/task_generators'
require_relative '../lib/http_stub'
require_relative '../examples/configurer_with_class_activator'
require_relative '../examples/configurer_with_many_class_activators'
require_relative '../examples/configurer_with_class_stub'
require_relative '../examples/configurer_with_initialize_callback'
require_relative '../examples/configurer_with_complex_initializer'
require_relative '../examples/configurer_with_response_defaults'
require_relative '../examples/configurer_with_file_response'

HttpStub::Server::Daemon.log_dir = ::File.expand_path('../../tmp/log', __FILE__)
HttpStub::Server::Daemon.pid_dir = ::File.expand_path('../../tmp/pids', __FILE__)

HttpServerManager.logger = HttpServerManager::Test::SilentLogger

module HttpStub

  module Spec
    RESOURCES_DIR = ::File.expand_path('../resources', __FILE__)
  end

end

Dir[::File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require file }
