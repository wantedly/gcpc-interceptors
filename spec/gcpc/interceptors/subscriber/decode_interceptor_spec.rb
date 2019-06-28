require "spec_helper"
require "support/fakes"

describe Gcpc::Interceptors::Subscriber::DecodeInterceptor do
  describe "#handle" do
    subject { handle_engine.handle(message) }

    let(:handle_engine) {
      Gcpc::Subscriber::HandleEngine.new(
        handler:      handler,
        interceptors: [
          Gcpc::Interceptors::Subscriber::DecodeInterceptor.new(
            strategy: strategy,
            logger:   logger,
          )
        ],
      )
    }
    let(:handler) { FakeHandler.new }
    let(:message) { FakeMessage.new(data: data, attributes: {}) }
    let(:logger) { FakeLogger.new }

    context "when strategy is JSONStrategy" do
      let(:strategy) {
        Gcpc::Interceptors::Subscriber::DecodeInterceptor::JSONStrategy.new
      }
      context "when decode is successfull" do
        let(:data) { '{ "id": "33", "name": "Taro" }' }

        it "decodes data" do
          expect(handler).to receive(:handle)
            .with({ "id" => "33", "name" => "Taro" }, {}, message)
          subject
        end
      end

      context "when decode failed" do
        let(:data) { 'invalid' }

        it "skips handling message" do
          expect(handler).not_to receive(:handle)
          expect(message).to receive(:ack!)
          subject
          error = logger.messages[:error].first
          expect(error.inspect).to eq "#<JSON::ParserError: 767: unexpected token at 'invalid'>"
          info = logger.messages[:info].first
          expect(info.inspect).to eq "\"Ack a message{data=invalid, attributes={}} because it can't be decoded!\""
        end
      end
    end
  end

  describe "#initialize" do
    context "when ignore_on_error is false" do
      let(:handle_engine) {
        Gcpc::Subscriber::HandleEngine.new(
          handler:      handler,
          interceptors: [
            Gcpc::Interceptors::Subscriber::DecodeInterceptor.new(
              strategy:        strategy,
              logger:          FakeLogger.new,
              ignore_on_error: false,
            )
          ],
        )
      }
      let(:strategy) {
        Gcpc::Interceptors::Subscriber::DecodeInterceptor::JSONStrategy.new
      }
      let(:handler) { FakeHandler.new }
      let(:message) { FakeMessage.new(data: data, attributes: {}) }
      let(:data) { 'invalid' }

      it "raises exception when decode failed" do
        expect { handle_engine.handle(message) }.to raise_error(JSON::ParserError, "767: unexpected token at 'invalid'")
      end
    end
  end
end
