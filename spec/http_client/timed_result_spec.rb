# encoding: utf-8

require 'http_api_client/timed_result'

module HttpApiClient

  describe TimedResult do

    context 'without extra log data' do

      let(:request_id) { 'abc-123' }
      let(:logger) { HttpApiClient.logger }

      before do
        TimedResult.stub(:millis_since).and_return 1000
        Thread.current[:request_id] = request_id
      end

      it 'logs event with base data' do
        logger.should_receive(:info).with("event_name=my_event, request_id=#{request_id}, timing=#{1000}")
        TimedResult.time('my_event') {  }
      end

      it 'logs event with extra data' do
        logger.should_receive(:info).with("event_name=my_event, request_id=#{request_id}, timing=#{1000}, foo=bar")
        TimedResult.time('my_event', { foo: 'bar' }) {  }
      end

    end
  end
end