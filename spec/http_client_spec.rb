require 'http_client'

describe HttpClient do

  context "without rails" do

    describe ".env" do
      it 'returns "test" by default' do
        expect(HttpClient.env).to eq 'test'
      end

      it 'can be set' do
        HttpClient.env = 'staging'
        expect(HttpClient.env).to eq 'staging'
        HttpClient.env = nil
      end
    end

    describe ".logger" do
      it 'returns a stub logger' do
        expect(HttpClient.logger).to_not be_nil
      end
    end

  end

  context "with rails" do
    before :all do
      Object.const_set('Rails', StubRails.new)
      Rails.env = 'custom_env'
      Rails.logger = 'rails_logger'
    end

    after :all do
      Object.const_set('Rails', nil)
    end

    describe ".env" do
      it 'returns the current rails environment' do
        expect(HttpClient.env).to eq Rails.env
      end
    end

    describe ".logger" do
      it 'returns the rails logger' do
        expect(HttpClient.logger).to eq Rails.logger
      end
    end

  end

  class StubRails

    attr_accessor :env, :logger

  end

end