describe HttpStub::Server::Application::Routes::Memory do
  include_context "http_stub rack application test"

  let(:memory_controller) { instance_double(HttpStub::Server::Memory::Controller) }

  before(:example) { allow(HttpStub::Server::Memory::Controller).to receive(:new).and_return(memory_controller) }

  context "when a request to show the servers memory is received" do

    subject { get "/http_stub/memory" }

    it "retrieves the servers memorized stub via the memory controller" do
      memorized_stubs = (1..3).map { HttpStub::Server::Stub::Empty::INSTANCE }
      expect(memory_controller).to receive(:find_stubs).and_return(memorized_stubs)

      subject
    end

  end

  context "when a request to reset the servers memory is received" do

    subject { delete "/http_stub/memory" }

    before(:example) { allow(memory_controller).to receive(:reset) }

    it "resets the servers memory via the memory controller" do
      expect(memory_controller).to receive(:reset)

      subject
    end

    it "responds without error" do
      subject

      expect(response.status).to eql(200)
    end

  end

end
