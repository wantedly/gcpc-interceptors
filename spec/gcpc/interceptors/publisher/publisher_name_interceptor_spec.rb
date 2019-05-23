require "spec_helper"
require "gcpc/interceptors/publisher/publisher_name_interceptor"

describe Gcpc::Interceptors::Publisher::PublisherNameInterceptor do
  describe "#publish" do
    let(:publisher) {
      Gcpc::Publisher::Engine.new(
        topic:        topic,
        interceptors: [
          Gcpc::Interceptors::Publisher::PublisherNameInterceptor.new(publisher: "publisher-A")
        ],
      )
    }
    let(:topic) { double(:topic) }

    it "adds a publisher name to a message's attributes" do
      expect(topic).to receive(:publish)
        .with("", { "published_by" => "publisher-A" })
      publisher.publish("", {})
    end
  end
end
