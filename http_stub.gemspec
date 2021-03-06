# -*- encoding: utf-8 -*-
$LOAD_PATH.push ::File.expand_path("../lib", __FILE__)
require "http_stub/version"

Gem::Specification.new do |spec|
  spec.name              = "http_stub"
  spec.version           = HttpStub::VERSION
  spec.platform          = Gem::Platform::RUBY
  spec.authors           = %w{ dueckes rvanbert rypac andykingking campezzi }
  spec.summary           = "A service virtualization tool that encourages contract based testing"
  spec.description       = "A service virtualization tool that encourages contract based tests in API consumers and producers"
  spec.email             = "matthew.ueckerman@myob.com"
  spec.homepage          = "http://github.com/MYOB-Technology/http_stub"
  spec.rubyforge_project = "http_stub"
  spec.license           = "MIT"

  spec.files      = Dir.glob("./lib/**/*")
  spec.test_files = Dir.glob("./spec/**/*")

  spec.require_path = "lib"

  spec.required_ruby_version = ">= 2.2.2"

  spec.add_runtime_dependency "rake", ">= 10.4"

  spec.add_dependency "sinatra",             "~> 1.4"
  spec.add_dependency "sinatra-contrib",     "~> 1.4"
  spec.add_dependency "sinatra-partial",     "~> 1.0"
  spec.add_dependency "multipart-post",      "~> 2.0"
  spec.add_dependency "http_server_manager", "~> 0.5"
  spec.add_dependency "json-schema",         "~> 2.7"
  spec.add_dependency "activesupport",       "~> 5.0"
  spec.add_dependency "haml",                "~> 4.0"
  spec.add_dependency "sass",                "~> 3.4"

  spec.add_development_dependency "rubocop",                   "~> 0.47"
  spec.add_development_dependency "rspec",                     "~> 3.5"
  spec.add_development_dependency "nokogiri",                  "~> 1.7"
  spec.add_development_dependency "httparty",                  "~> 0.14"
  spec.add_development_dependency "rack-test",                 "~> 0.6"
  spec.add_development_dependency "wait_until",                "~> 0.3"
  spec.add_development_dependency "selenium-webdriver",        "~> 3.0"
  spec.add_development_dependency "simplecov",                 "~> 0.13"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0"
  spec.add_development_dependency "travis-lint",               "~> 2.0"
end
