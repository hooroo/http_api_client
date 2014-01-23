
require 'places_http/errors'

module PlacesHttp
  module Errors

    describe BaseError do

      let(:nested_error)  { double('nested', message: 'nested_message') }

      let(:error) { BaseError.new("message", "response_body", nested_error) }

      it "stores the response_body" do
        expect(error.response_body).to eq "response_body"
      end

      it "stores the nested_error" do
        expect(error.nested_error).to eq nested_error
      end

      it "returns the message in message (duh)" do
        expect(error.message).to include "message"
      end

      it "returns the response_body in message" do
        expect(error.message).to include "response_body"
      end

      it "returns the nested_error in message" do
        expect(error.message).to include "nested_message"
      end

    end
  end
end