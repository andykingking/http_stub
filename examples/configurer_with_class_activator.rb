module HttpStub
  module Examples

    class ConfigurerWithClassActivator
      include HttpStub::Configurer

      stub_activator "/an_activator", "/stub_path", method: :get, response: { status: 200, body: "Stub activator body" }
    end

  end
end
