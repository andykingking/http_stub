describe HttpStub::Server::Daemon do

  let(:server) { HttpStub::Server::Daemon.new(name: :example_server_daemon, port: 8002) }

  it_behaves_like "a managed http server"

end
