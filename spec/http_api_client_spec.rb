require 'http_api_client'

describe HttpApiClient do

  context "with an injected logger" do
    describe ".logger" do
      it "uses the injected logger" do
        HttpApiClient.logger = "my logger"
        expect(HttpApiClient.logger).to eq "my logger"
        HttpApiClient.logger = nil
      end
    end
  end

  context "without rails" do

    describe ".env" do
      it 'returns "test" by default' do
        expect(HttpApiClient.env).to eq 'test'
      end

      it 'can be set' do
        HttpApiClient.env = 'staging'
        expect(HttpApiClient.env).to eq 'staging'
        HttpApiClient.env = nil
      end
    end

    describe ".logger" do
      it 'returns a stub logger' do
        expect(HttpApiClient.logger).to_not be_nil
      end
    end

  end

  context "with rails" do

    before :each do
      allow(HttpApiClient).to receive(:rails).and_return(StubRails)
    end

    describe ".env" do
      it 'returns the current rails environment' do
        expect(HttpApiClient.env).to eq StubRails.env
      end
    end

    describe ".logger" do
      it 'returns the rails logger' do
        expect(HttpApiClient.logger).to eq StubRails.logger
      end
    end

  end

  class StubRails

    def self.env
      'custom_env'
    end

    def self.logger
      'rails_logger'
    end
  end

end