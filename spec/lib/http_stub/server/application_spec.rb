describe HttpStub::Server::Application do
  include Rack::Test::Methods

  let(:response)      { last_response }
  let(:response_body) { response.body.to_s }

  let(:match_registry)    { instance_double(HttpStub::Server::Stub::Registry).as_null_object }
  let(:stub_registry)     { instance_double(HttpStub::Server::Stub::Registry).as_null_object }
  let(:scenario_registry) { instance_double(HttpStub::Server::Registry).as_null_object }

  let(:stub_controller)     { instance_double(HttpStub::Server::Stub::Controller).as_null_object }
  let(:scenario_controller) { instance_double(HttpStub::Server::Scenario::Controller).as_null_object }

  let(:response_pipeline) { instance_double(HttpStub::Server::ResponsePipeline, process: nil) }

  let(:app) { HttpStub::Server::Application.new! }

  before(:example) do
    allow(HttpStub::Server::Registry).to receive(:new).with("match").and_return(match_registry)
    allow(HttpStub::Server::Registry).to receive(:new).with("scenario").and_return(scenario_registry)
    allow(HttpStub::Server::Stub::Registry).to receive(:new).and_return(stub_registry)
    allow(HttpStub::Server::Stub::Controller).to receive(:new).and_return(stub_controller)
    allow(HttpStub::Server::Scenario::Controller).to receive(:new).and_return(scenario_controller)
    allow(HttpStub::Server::ResponsePipeline).to receive(:new).and_return(response_pipeline)
  end

  context "when a stub registration request is received" do

    let(:registration_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject do
      post "/http_stub/stubs", { uri: "/a_path", method: "a method", response: { status: 200, body: "Foo" } }.to_json
    end

    before(:example) { allow(stub_controller).to receive(:register).and_return(registration_response) }

    it "registers the stub via the stub controller" do
      expect(stub_controller).to receive(:register).and_return(registration_response)

      subject
    end

    it "processes the stub controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(registration_response)

      subject
    end

  end

  context "when a request to list the stubs is received" do

    let(:found_stubs) { [ HttpStub::Server::Stub::Empty::INSTANCE ] }

    subject { get "/http_stub/stubs" }

    it "retrieves the stubs from the registry" do
      expect(stub_registry).to receive(:all).and_return(found_stubs)

      subject
    end

  end

  context "when a request to show a stub is received" do

    let(:stub_id)    { SecureRandom.uuid }
    let(:found_stub) { HttpStub::Server::Stub::Empty::INSTANCE }

    subject { get "/http_stub/stubs/#{stub_id}" }

    it "retrieves the stub from the registry" do
      expect(stub_registry).to receive(:find).with(stub_id, anything).and_return(found_stub)

      subject
    end

  end

  context "when a request to clear the stubs is received" do

    subject { delete "/http_stub/stubs" }

    it "delegates clearing to the stub controller" do
      expect(stub_controller).to receive(:clear)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to commit the stubs to memory is received" do

    subject { post "/http_stub/stubs/memory" }

    it "remembers the stubs in the stub registry" do
      expect(stub_registry).to receive(:remember)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to recall the stubs in memory is received" do

    subject { get "/http_stub/stubs/memory" }

    it "recalls the stubs remembered by the stub registry" do
      expect(stub_registry).to receive(:recall)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to list the matches is received" do

    let(:found_matches) { [ HttpStub::Server::Stub::Match::MatchFixture.empty ] }

    subject { get "/http_stub/stubs/matches" }

    it "retrieves the matches from the registry" do
      expect(match_registry).to receive(:all).and_return(found_matches)

      subject
    end

  end

  context "when a scenario registration request is received" do

    let(:registration_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    before(:example) { allow(scenario_controller).to receive(:register).and_return(registration_response) }

    subject do
      post "/http_stub/scenarios",
           {
             uri: "/a_scenario_path",
             stubs: [ { uri: "/a_path", method: "a method", response: { status: 200, body: "Foo" } } ],
             triggered_scenario_names: [ "some/uri/to/activate" ]
           }.to_json
    end

    it "registers the scenario via the scenario controller" do
      expect(scenario_controller).to receive(:register).and_return(registration_response)

      subject
    end

    it "processes the scenario controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(registration_response)

      subject
    end

  end

  shared_examples_for "a scenario activation request" do

    let(:scenario_name)       { "Some scenario name" }
    let(:activation_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    before(:example) { allow(scenario_controller).to receive(:activate).and_return(activation_response) }

    it "activates the scenario via the scenario controller" do
      expect(scenario_controller).to receive(:activate).with(scenario_name, anything).and_return(activation_response)

      subject
    end

    it "processes the scenario controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(activation_response)

      subject
    end

  end

  context "when a scenario activation request is received with a name parameter" do

    subject { get "/http_stub/scenarios", :name => scenario_name }

    it_behaves_like "a scenario activation request"

  end

  context "when a deprecated scenario activation request is received with the name encoded in the url" do

    subject { get "/http_stub/scenarios/#{URI.encode_www_form_component(scenario_name)}" }

    it_behaves_like "a scenario activation request"

  end

  context "when a request to list the scenarios is received" do

    let(:found_scenarios) { [ HttpStub::Server::Scenario::ScenarioFixture.empty ] }

    subject { get "/http_stub/scenarios" }

    it "retrieves the stubs from the registry" do
      expect(scenario_registry).to receive(:all).and_return(found_scenarios)

      subject
    end

  end

  context "when a request to clear the scenarios has been received" do

    subject { delete "/http_stub/scenarios" }

    it "delegates clearing to the scenario controller" do
      expect(scenario_controller).to receive(:clear)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when another type of request is received" do

    let(:stub_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { get "/a_path" }

    before(:example) { allow(stub_controller).to receive(:replay).and_return(stub_response) }

    it "attempts to replay a stub response via the stub controller" do
      expect(stub_controller).to receive(:replay).with(an_instance_of(HttpStub::Server::Request), anything)

      subject
    end

    it "processes the response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(stub_response)

      subject
    end

  end

end
