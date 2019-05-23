require "spec_helper"
require "support/fakes"
require "gcpc/interceptors/subscriber/check_dup_interceptor"

describe Gcpc::Interceptors::Subscriber::CheckDupInterceptor do
  describe "#handle" do
    subject { handle_engine.handle(message) }

    let(:handle_engine) {
      Gcpc::Subscriber::HandleEngine.new(
        handler:      handler,
        interceptors: [
          Gcpc::Interceptors::Subscriber::CheckDupInterceptor.new(
            store:    fake_store,
            strategy: strategy,
          )
        ],
      )
    }
    let(:handler) { FakeHandler.new }
    let(:message) { FakeMessage.new(data: "", attributes: attributes) }
    let(:fake_store) { FakeStore.new }

    let(:strategy) {
      Gcpc::Interceptors::Subscriber::CheckDupInterceptor::BaseStrategy.new
    }

    context "when message does not have message_id as attributes" do
      let(:attributes) { {} }

      it "invokes handler#handle" do
        expect(handler).to receive(:handle).with("", {}, message)
        subject
      end
    end

    context "when message_id is not stored in store" do
      let(:attributes) { { "message_id" => "12345" } }

      it "invokes handler#handle" do
        expect(handler).to receive(:handle)
          .with("", { "message_id" => "12345" }, message)
        subject
      end
    end

    context "when message_id is already stored in store" do
      let(:attributes) { { "message_id" => "12345" } }

      before do
        fake_store.set("CheckDupInterceptor:key:12345", "exists")
      end

      it "does not invoke handler#handle" do
        expect(handler).not_to receive(:handle)
        subject
      end
    end
  end
end
