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
          )
        ],
      )
    }
    let(:handler) { FakeHandler.new }
    let(:message) { FakeMessage.new(data: data, attributes: {}) }

    context "when strategy is JSONStrategy" do
      let(:strategy) {
        Gcpc::Interceptors::Subscriber::DecodeInterceptor::JSONStrategy.new
      }
      let(:data) { '{ "id": "33", "name": "Taro" }' }

      it "decodes data" do
        expect(handler).to receive(:handle)
          .with({ "id" => "33", "name" => "Taro" }, {}, message)
        subject
      end
    end
  end
end
