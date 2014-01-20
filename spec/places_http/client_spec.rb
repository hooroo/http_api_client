# require 'spec_helper'
require 'places_http/client'
module PlacesHttp
  describe Client do

    let(:client) { Client.new(:my_client, 'spec/config/http_clients.yml') }

    let(:get_response) { double('get response', :body => '{"id": 1}', status: 200) }
    let(:post_response) { double('post response', :body => '{"id": 1}', status: 200) }
    let(:put_response) { double('put response', :body => '{"id": 1}', status: 200) }
    let(:delete_response) { double('delete response', status: 200, body: nil) }

    let(:connection) { double('connection', get: get_response, post: post_response, put: put_response, delete: delete_response) }

    before do
      client.stub(:connection).and_return connection
    end

    describe "#find" do
      it "calls http connection with get and correct url" do
        connection.should_receive(:get).with('/test-base-uri/path/1')
        client.find('/path', 1)
      end
    end

    describe "#find_nested" do
      it "calls http connection with get and correct url" do
        connection.should_receive(:get).with('/test-base-uri/resource/1/resources')
        client.find_nested('/resource', 1, '/resources')
      end
    end

    describe "#create" do
      it "calls http connection with post and correct url and post data" do
        payload = { text: "hello" }
        connection.should_receive(:post).with('/test-base-uri/path', payload.to_query)
        client.create('/path', payload)
      end
    end

    describe "#delete" do
      it "calls http connection with delete and correct url" do
        connection.should_receive(:delete).with('/test-base-uri/path/1')
        client.destroy('/path', 1)
      end
    end

    describe "#find_all" do
      it "calls http connection with correct url without query" do
        connection.should_receive(:get).with('/test-base-uri/resources')
        client.find_all('/resources')
      end

      it "calls http connection with correct url with query" do
        connection.should_receive(:get).with('/test-base-uri/resources?a=1')
        client.find_all('/resources', {a: 1})
      end
    end

    describe "response status code handling" do

      context "with a response with a status code in the 200 range" do

        let(:response) { double('response', :body => '{"id": 1}', status: 200) }

        describe "response" do
          it "returns expected response body as hash" do
            response = client.find('/path', 1)
            expect(response['id']).to eq 1
          end
        end
      end

      context "with a response in the 400 range" do
        let(:get_response) { double('response', :body => '{"id": 1}', status: 404) }

        describe "raising exceptions" do
          it "raises the expected exception for the status" do
            lambda { client.find('/path', 1) }.should raise_error(Errors::NotFound)
          end
        end
      end

      context "with a response in the 500 range" do
        let(:get_response) { double('response', :body => '{"id": 1}', status: 500) }

        describe "raising exceptions" do
          it "raises the expected exception for the status" do
            lambda { client.find('/path', 1) }.should raise_error(Errors::InternalServerError)
          end
        end
      end

    end

  end
end