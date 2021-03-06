describe HttpStub::Server::Stub::Response::Base do

  let(:status)           { 202 }
  let(:headers)          { nil }
  let(:delay_in_seconds) { 18 }
  let(:args)             { { "status" => status, "headers" => headers, "delay_in_seconds" => delay_in_seconds } }

  let(:testable_response_class) { Class.new(described_class) }

  let(:response) { testable_response_class.new(args) }

  describe "#status" do

    context "when a value is provided in the arguments" do

      context "that is an integer" do

        it "returns the value provided" do
          expect(response.status).to eql(status)
        end

      end

      context "that is an empty string" do

        let(:status) { "" }

        it "defaults to 200" do
          expect(response.status).to eql(200)
        end

      end

    end

    context "when the status is not provided in the arguments" do

      let(:args) { { "headers" => headers } }

      it "defaults to 200" do
        expect(response.status).to eql(200)
      end

    end

  end

  describe "#delay_in_seconds" do

    context "when a value is provided in the arguments" do

      context "that is an integer" do

        it "returns the value" do
          expect(response.delay_in_seconds).to eql(delay_in_seconds)
        end

      end

      context "that is an empty string" do

        let(:delay_in_seconds) { "" }

        it "defaults to 0" do
          expect(response.delay_in_seconds).to eql(0)
        end

      end

    end

    context "when a value is not provided in the arguments" do

      let(:args) { { "status" => status } }

      it "defaults to 0" do
        expect(response.delay_in_seconds).to eql(0)
      end

    end

  end

  describe "#headers" do

    let(:response_header_hash) { response.headers.to_hash }

    it "is interpolateable headers" do
      expect(response.headers).to be_a(HttpStub::Server::Stub::Response::Attribute::Headers)
    end

    context "when default headers have been added" do

      let(:default_headers) do
        { "a_default_header" => "a default value", "another_default_header" => "some other default value" }
      end

      before(:example) { testable_response_class.add_default_headers(default_headers) }

      context "and headers are provided" do

        context "that have some names matching the defaults" do

          let(:headers) { { "a_default_header" => "an overridde value" } }

          it "replaces the matching default values with those provided" do
            expect(response_header_hash["a_default_header"]).to eql("an overridde value")
          end

          it "preserves the default values that do not match" do
            expect(response_header_hash["another_default_header"]).to eql("some other default value")
          end

        end

        context "that do not have names matching the defaults" do

          let(:headers) do
            {
              "a_header" => "some header",
              "another_header" => "another value",
              "yet_another_header" => "yet another value"
            }
          end

          it "returns the defaults headers combined with the provided headers" do
            expect(response_header_hash).to eql(default_headers.merge(headers))
          end

        end

      end

      context "and no headers are provided" do

        it "returns the default headers" do
          expect(response_header_hash).to eql(default_headers)
        end

      end

    end

    context "when no default headers have been added" do

      context "and headers are provided" do

        let(:headers) do
          {
            "a_header" => "some header",
            "another_header" => "another value",
            "yet_another_header" => "yet another value"
          }
        end

        it "returns the headers" do
          expect(response_header_hash).to eql(headers)
        end

      end

      context "and no headers are provided" do

        let(:headers) { nil }

        it "returns an empty hash" do
          expect(response_header_hash).to eql({})
        end

      end

    end

  end

  describe "#type" do

    class HttpStub::Server::Stub::Response::TestableBaseClass < HttpStub::Server::Stub::Response::Base
    end

    let(:testable_response_class) { HttpStub::Server::Stub::Response::TestableBaseClass }

    it "returns the name of the concrete base instance underscored" do
      expect(response.type).to eql("testable_base_class")
    end

  end

  describe "#to_hash" do

    subject { response.to_hash }

    it "contains the responses status" do
      expect(subject).to include(status: response.status)
    end

    it "contains the responses headers" do
      expect(subject).to include(headers: response.headers)
    end

    it "contains the responses delay in seconds" do
      expect(subject).to include(delay_in_seconds: response.delay_in_seconds)
    end

  end

  describe "#to_json" do

    subject { response.to_json }

    it "is the JSON representation of the responses hash" do
      expect(subject).to eql(response.to_hash.to_json)
    end

  end

end
