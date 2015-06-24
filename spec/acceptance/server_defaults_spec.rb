describe "Server defaults acceptance" do
  include_context "configurer integration"

  context "when a configurer defines server defaults" do

    let(:configurer) { HttpStub::Examples::ConfigurerWithServerDefaults.new }

    before(:example) { configurer.class.initialize! }

    it "matches requests that match the request default rules" do
      response = issue_matching_request("has_defaults")

      expect(response.code).to eql(203)
    end

    it "does not match requests that do not match the request default rules" do
      response = HTTParty.get("#{server_uri}/has_defaults")

      expect(response.code).to eql(404)
    end

    it "includes the response defaults in a match" do
      response = issue_matching_request("has_defaults")

      expect(response.code).to eql(203)
      expect(response.body).to eql("Some body")
      expect(response.headers["defaulted_response_header"]).to eql("Response header value")
    end

    it "includes the response defaults in all matches" do
      response = issue_matching_request("also_has_defaults")

      expect(response.code).to eql(203)
      expect(response.body).to eql("Also some body")
      expect(response.headers["defaulted_response_header"]).to eql("Response header value")
    end

    def issue_matching_request(uri)
      HTTParty.get("#{server_uri}/#{uri}", headers: { "defaulted_request_header" => "Request header value"})
    end

  end

end