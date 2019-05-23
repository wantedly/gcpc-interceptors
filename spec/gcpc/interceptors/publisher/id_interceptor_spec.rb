require "spec_helper"
require "gcpc/interceptors/publisher/id_interceptor"

describe Gcpc::Interceptors::Publisher::IdInterceptor do
  describe "#publish" do
    let(:publisher) {
      Gcpc::Publisher::Engine.new(
        topic:        topic,
        interceptors: interceptors
      )
    }
    let(:topic) { double(:topic) }

    before do
      allow(SecureRandom).to receive(:uuid)
        .and_return("792ec4a9-ae0c-46b7-a14d-24e7e5db7d36")
    end

    context "when id_key is not specified" do
      let(:interceptors) {
        [Gcpc::Interceptors::Publisher::IdInterceptor.new]
      }

      it "adds message id as attributes[\"message_id\"]" do
        expect(topic).to receive(:publish)
          .with("", { "message_id" => "792ec4a9-ae0c-46b7-a14d-24e7e5db7d36" })
        publisher.publish("", {})
      end
    end

    context "when id_key is X-Message-Id" do
      let(:interceptors) {
        [Gcpc::Interceptors::Publisher::IdInterceptor.new(id_key: "X-Message-Id")]
      }

      it "adds message id as attributes[\"X-Message-Id\"]" do
        expect(topic).to receive(:publish)
          .with("", { "X-Message-Id" => "792ec4a9-ae0c-46b7-a14d-24e7e5db7d36" })
        publisher.publish("", {})
      end
    end
  end
end
