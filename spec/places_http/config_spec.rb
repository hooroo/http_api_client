# require 'spec_helper'
require 'places_http/config'
module PlacesHttp

  describe Config do

    let(:config) { Config.new(config_file) }

    context "with an invalid config file" do

      let(:config_file) { 'invalid' }

      it "raises error" do
        expect{ config }.to raise_error("Could not load config file: #{config_file}")
      end
    end

    context "with a valid config file" do

      let(:config_file) { 'spec/config/http_clients.yml' }

      it 'loads the config for the environment' do
        expect(config.my_client.server).to eql 'test-server'
        expect(config.my_client.port).to eql 'test-port'
        expect(config.my_client.base_uri).to eql 'test-base-uri'
      end
    end

  end

end