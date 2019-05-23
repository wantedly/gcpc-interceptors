require "spec_helper"
require "timecop"
require "gcpc/interceptors/publisher/timestamp_interceptor"

describe Gcpc::Interceptors::Publisher::TimestampInterceptor do
  describe "#publish" do
    let(:publisher) {
      Gcpc::Publisher::Engine.new(
        topic:        topic,
        interceptors: interceptors
      )
    }
    let(:topic) { double(:topic) }

    context "when timestamp_key is not specified" do
      let(:interceptors) {
        [Gcpc::Interceptors::Publisher::TimestampInterceptor.new]
      }

      it "adds a published timestamp as attributes[\"published_at\"]" do
        expect(topic).to receive(:publish)
          .with("", { "published_at" => "2019-03-01T00:00:00+00:00" })
        Timecop.freeze(Time.new(2019, 3, 1)) do
          publisher.publish("", {})
        end
      end
    end

    context "when timestamp_key is X-Published-At" do
      let(:interceptors) {
        [
          Gcpc::Interceptors::Publisher::TimestampInterceptor.new(
            timestamp_key: "X-Published-At"
          )
        ]
      }

      it "adds a published timestamp as attributes[\"X-Published-At\"]" do
        expect(topic).to receive(:publish)
          .with("", { "X-Published-At" => "2019-03-01T00:00:00+00:00" })
        Timecop.freeze(Time.new(2019, 3, 1)) do
          publisher.publish("", {})
        end
      end
    end
  end
end
