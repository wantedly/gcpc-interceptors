require "spec_helper"
require "gcpc/interceptors/publisher/encode_interceptor"

describe Gcpc::Interceptors::Publisher::EncodeInterceptor do
  describe "#publish" do
    let(:publisher) {
      Gcpc::Publisher::Engine.new(
        topic:        topic,
        interceptors: [
          Gcpc::Interceptors::Publisher::EncodeInterceptor.new(content_type: content_type),
        ],
      )
    }
    let(:topic) { double(:topic) }
    let(:data) { double(:data) }

    context "when content_type is :json" do
      let(:content_type) { :json }
      let(:json_data) { double(:json_data) }

      before do
        allow(data).to receive(:dup).and_return(data)
        allow(data).to receive(:to_json).and_return(json_data)
      end

      it "calls data.to_json before publish" do
        expect(topic).to receive(:publish)
          .with(json_data, { "content_type" => "json" })
        publisher.publish(data, {})
      end
    end

    context "when content_type is :json" do
      let(:content_type) { :protobuf }
      let(:protobuf_data) { double(:protobuf_data) }

      before do
        allow(data).to receive(:dup).and_return(data)
        allow(data).to receive(:to_proto).and_return(protobuf_data)
      end

      it "calls data.to_proto before publish" do
        expect(topic).to receive(:publish)
          .with(protobuf_data, { "content_type" => "protobuf" })
        publisher.publish(data, {})
      end
    end
  end
end
