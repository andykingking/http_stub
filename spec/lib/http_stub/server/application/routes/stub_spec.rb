describe HttpStub::Server::Application::Routes::Stub do
  include_context "http_stub rack application test"

  let(:stub_controller)       { instance_double(HttpStub::Server::Stub::Controller) }
  let(:stub_match_controller) { instance_double(HttpStub::Server::Stub::Match::Controller) }

  before(:example) do
    allow(HttpStub::Server::Stub::Controller).to receive(:new).and_return(stub_controller)
    allow(HttpStub::Server::Stub::Match::Controller).to receive(:new).and_return(stub_match_controller)
  end

  describe "when a stub registration request within a session is received" do
    include_context "request includes a session identifier"

    let(:payload) { { uri: "/a_path", method: "a method", response: { status: 200, body: "Foo" } }.to_json }

    let(:registration_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { post "/http_stub/stubs" }

    before(:example) do
      allow(request).to receive(:body).and_return(payload)
      allow(stub_controller).to receive(:register).and_return(registration_response)
    end

    it "registers the stub via the stub controller" do
      expect(stub_controller).to receive(:register).and_return(registration_response)

      subject
    end

    it "processes the stub controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(registration_response)

      subject
    end

  end

  describe "when a request to list the stubs in a session is received" do
    include_context "request includes a session identifier"

    let(:found_stubs) { [ HttpStub::Server::Stub::Empty::INSTANCE ] }

    subject { get "/http_stub/stubs" }

    it "retrieves the stubs for the current user via the stub controller" do
      expect(stub_controller).to receive(:find_all).with(request).and_return(found_stubs)

      subject
    end

  end

  describe "when a request to show a stub in a session is received" do
    include_context "request includes a session identifier"

    let(:stub_id) { SecureRandom.uuid }

    let(:found_stub) { HttpStub::Server::Stub::Empty::INSTANCE }

    subject { get "/http_stub/stubs/#{stub_id}" }

    before(:example) { allow(stub_controller).to receive(:find).and_return(found_stub) }

    it "retrieves the stub for the current user via the stub controller" do
      expect(stub_controller).to receive(:find).with(request, anything).and_return(found_stub)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  describe "when a request to reset the stubs in a session is received" do
    include_context "request includes a session identifier"

    subject { post "/http_stub/stubs/reset" }

    before(:example) { allow(stub_controller).to receive(:reset) }

    it "resets the stubs in the session via the stub controller" do
      expect(stub_controller).to receive(:reset).with(request, anything)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  describe "when a request to clear the stubs in a session is received" do
    include_context "request includes a session identifier"

    subject { delete "/http_stub/stubs" }

    before(:example) { allow(stub_controller).to receive(:clear) }

    it "clears the stubs for the current user via the stub controller" do
      expect(stub_controller).to receive(:clear).with(request, anything)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  describe "when a request to list the stub matches in a session is received" do
    include_context "request includes a session identifier"

    let(:found_matches) { [ HttpStub::Server::Stub::Match::MatchFixture.create ] }

    subject { get "/http_stub/stubs/matches" }

    it "retrieves the matches for the current user via the stub match controller" do
      expect(stub_match_controller).to receive(:matches).with(request).and_return(found_matches)

      subject
    end

  end

  describe "when a request to retrieve the last match for an endpoint in a session is received" do
    include_context "request includes a session identifier"

    let(:uri)                 { "/some/matched/uri" }
    let(:method)              { "some http method" }
    let(:last_match_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { get "/http_stub/stubs/matches/last" }

    before(:example) do
      allow(request).to receive(:parameters).and_return(uri: uri, method: method)
      allow(stub_match_controller).to receive(:last_match).and_return(last_match_response)
    end

    it "retrieves the last match for the user via the match result controller" do
      expect(stub_match_controller).to receive(:last_match).with(request, anything)

      subject
    end

    it "processes the match result controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(last_match_response)

      subject
    end

  end

  describe "when a request to list the stub misses in a session is received" do
    include_context "request includes a session identifier"

    let(:found_misses) { [ HttpStub::Server::Stub::Match::MissFixture.create ] }

    subject { get "/http_stub/stubs/misses" }

    it "retrieves the misses for the current user via the stub match controller" do
      expect(stub_match_controller).to receive(:misses).with(request).and_return(found_misses)

      subject
    end

  end

  describe "when any other request is received" do

    let(:stub_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { get "/some_path" }

    before(:example) { allow(stub_controller).to receive(:match).and_return(stub_response) }

    it "attempts to match the request to a stub response via the stub controller" do
      expect(stub_controller).to receive(:match).with(request, anything)

      subject
    end

    it "processes the response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(stub_response)

      subject
    end

  end

end
