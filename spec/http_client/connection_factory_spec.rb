# encoding: utf-8

# require 'spec_helper'

require 'http_api_client/connection_factory'
require 'http_api_client/config'

module HttpApiClient

  describe ConnectionFactory do


    let(:config) { Config.new(config_file).send(client_id) }
    let(:client_id) { 'my_client' }
    let(:connection_factory) { ConnectionFactory.new(config) }
    let(:connection) { connection_factory.create }

    context "without ssl" do

      let(:config_file) { 'spec/config/http_api_clients.yml' }

      it "creates a connection based on config" do
        expect(connection.url_prefix.to_s).to eq 'http://test-server/'
      end

      it "caches the connection for reuse" do
        expect(connection).to eq connection
      end
    end

    context "with ssl" do

      context 'when a self-signed certificate authority is specified' do

        let(:config_file) { 'spec/config/http_api_clients_with_self_signed_cert.yml' }

        it "creates a connection based on config" do
          expect(connection.url_prefix.to_s).to eq 'https://test-server/'
        end

        it 'sets ca_file path correctly' do
          expect(connection.ssl.ca_file).to eq '/usr/local/etc/nginx/test-server.crt'
        end
      end

      context 'when the machine is OSX' do

        let(:config_file) { 'spec/config/http_api_clients_with_ssl.yml' }

        before { connection_factory.stub(osx?: true) }

        it "creates a connection based on config" do
          expect(connection.url_prefix.to_s).to eq 'https://test-server/'
        end

        it "sets the ssl options" do
          expect(Array(ConnectionFactory::OSX_CERT_PATH)).to include(connection.ssl.ca_file)
        end
      end

      context 'when the machine is not OSX' do

        let(:config_file) { 'spec/config/http_api_clients_with_ssl.yml' }

        before { connection_factory.stub(osx?: false) }

        it "creates a connection based on config" do
          expect(connection.url_prefix.to_s).to eq 'https://test-server/'
        end

        it "sets the ssl options" do
          expect(connection.ssl.ca_path).to eq '/etc/ssl/certs'
        end
      end
    end

    describe 'http basic auth' do

      context 'when auth is not specified' do

        let(:config_file) { 'spec/config/http_api_clients.yml' }

        it 'does not set the auth on the connection' do
          expect(connection.headers[:Authorization]).to be_nil
        end
      end

      context 'when auth is specified' do

        let(:config_file) { 'spec/config/http_api_clients_with_basic_auth.yml' }

        it 'sets the auth on the connection' do
          expect(connection.headers[:Authorization]).to_not be_nil
        end
      end
    end
  end

end
