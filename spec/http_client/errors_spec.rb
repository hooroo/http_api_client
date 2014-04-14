# encoding: utf-8


require 'http_api_client/errors'

module HttpApiClient
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
    describe UnprocessableEntity do
      let(:exception) {described_class.new(message,Oj.dump(response_body))}
      let(:response_body) {{'some' => 'json thing'}}
      let(:message) { 'this is a message that is really informative and stuff and junk'}

      it "is a BaseError" do
        expect(exception).to be_a_kind_of(BaseError)
      end
      describe "#as_json" do
        it "returns the response_body parsed" do
          expect(exception.as_json).to eq(response_body)
        end
      end
    end
  end
end