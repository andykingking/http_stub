describe HttpStub::Server::StubController do

  let(:request)            { double("HttpRequest") }
  let(:response)           { double(HttpStub::Server::Response) }
  let(:the_stub)           { double(HttpStub::Server::Stub, response: response) }
  let(:registry)           { double(HttpStub::Server::Registry).as_null_object }
  let(:request_translator) { double(HttpStub::Server::RequestTranslator, translate: the_stub) }

  let(:controller) { HttpStub::Server::StubController.new(registry) }

  before(:example) { allow(HttpStub::Server::RequestTranslator).to receive(:new).and_return(request_translator) }

  describe "#constructor" do

    it "creates a request translator that translates requests to stubs" do
      expect(HttpStub::Server::RequestTranslator).to receive(:new).with(HttpStub::Server::Stub)

      controller
    end

  end

  describe "#register" do

    subject { controller.register(request) }

    it "translates the request to a stub" do
      expect(request_translator).to receive(:translate).with(request).and_return(the_stub)

      subject
    end

    it "adds the stub to the stub registry" do
      expect(registry).to receive(:add).with(the_stub, request)

      subject
    end

    it "returns a success response" do
      expect(subject).to eql(HttpStub::Server::Response::SUCCESS)
    end

  end

  describe "#replay" do

    describe "when a stub has been registered that should be replayed for the request" do

      before(:example) do
        allow(registry).to receive(:find_for).with(request).and_return(the_stub)
      end

      it "returns the stubs response" do
        expect(the_stub).to receive(:response).and_return(response)

        expect(controller.replay(request)).to eql(response)
      end

    end

    describe "when no stub should be replayed for the request" do

      before(:example) do
        allow(registry).to receive(:find_for).with(request).and_return(nil)
      end

      it "returns an empty response" do
        expect(controller.replay(request)).to eql(HttpStub::Server::Response::EMPTY)
      end

    end

  end

  describe "#clear" do

    it "clears the stub registry" do
      expect(registry).to receive(:clear).with(request)

      controller.clear(request)
    end

  end

end
