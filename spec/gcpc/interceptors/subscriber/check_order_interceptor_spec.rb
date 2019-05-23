require "spec_helper"
require "support/fakes"
require "gcpc/interceptors/subscriber/check_order_interceptor"

describe Gcpc::Interceptors::Subscriber::CheckOrderInterceptor do
  describe "#handle" do
    subject { handle_engine.handle(message) }

    let(:handle_engine) {
      Gcpc::Subscriber::HandleEngine.new(
        handler:      handler,
        interceptors: [
          Gcpc::Interceptors::Subscriber::CheckOrderInterceptor.new(
            store:    fake_store,
            logger:   logger,
            strategy: raise_exception_strategy,
          )
        ],
      )
    }
    let(:handler) { FakeHandler.new }
    let(:message) { FakeMessage.new(data: "", attributes: attributes) }
    let(:fake_store) { FakeStore.new }
    let(:logger) { Logger.new(nil) }
    let(:raise_exception_strategy) {
      Class.new(Gcpc::Interceptors::Subscriber::CheckOrderInterceptor::BaseStrategy) do
        def on_swapped(data, attributes, message, &block)
          raise "Swapped!"
        end
      end.new
    }

    context "when message does not have published_at as attributes" do
      let(:attributes) { {} }

      it "invokes handler#handle" do
        expect(handler).to receive(:handle).with("", {}, message)
        subject
      end
    end

    context "when published_at is not stored" do
      let(:attributes) { { "published_at" => DateTime.new(2019, 3, 1).rfc3339 } }

      it "invokes handler#handle and stores new message's timestamp" do
        expect(handler).to receive(:handle)
          .with("", { "published_at" => "2019-03-01T00:00:00+00:00" }, message)
        subject
        expect(fake_store.get("CheckOrderInterceptor:key:same-id"))
          .to eq DateTime.new(2019, 3, 1).rfc3339
      end
    end

    context "when published_at is already stored and older than new message" do
      let(:attributes) { { "published_at" => DateTime.new(2019, 3, 1).rfc3339 } }

      before do
        fake_store.set("CheckOrderInterceptor:key:same-id", DateTime.new(2019, 2, 1).rfc3339)
      end

      it "invokes handler#handle and stores new message's timestamp" do
        expect(handler).to receive(:handle)
          .with("", { "published_at" => "2019-03-01T00:00:00+00:00" }, message)
        subject
        expect(fake_store.get("CheckOrderInterceptor:key:same-id"))
          .to eq DateTime.new(2019, 3, 1).rfc3339
      end
    end

    context "when published_at is already stored and newer than new message" do
      let(:attributes) { { "published_at" => DateTime.new(2019, 3, 1).rfc3339 } }

      before do
        fake_store.set("CheckOrderInterceptor:key:same-id", DateTime.new(2019, 4, 1).rfc3339)
      end

      it "raises swapped an error and stores new message's timestamp" do
        expect { subject }.to raise_error("Swapped!")
      end
    end

    context "when published_at is stored in invalid format" do
      let(:attributes) { { "published_at" => DateTime.new(2019, 3, 1).rfc3339 } }

      before do
        fake_store.set("CheckOrderInterceptor:key:same-id", "invalid format")
      end

      it "raises swapped an error and stores new message's timestamp" do
        expect(logger)
          .to receive(:error)
          .with("Failed to decode a stored timestamp! The stored value is \"invalid format\"!")
        expect { subject }.to raise_error("Swapped!")
        expect(fake_store.get("CheckOrderInterceptor:key:same-id"))
          .to eq DateTime.new(2019, 3, 1).rfc3339
      end
    end
  end
end
