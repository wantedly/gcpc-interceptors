require "spec_helper"
require "mock_redis"

describe Gcpc::Interceptors::Utils::RedisStore do
  let(:redis_store) {
    Gcpc::Interceptors::Utils::RedisStore.new(redis: redis)
  }
  let(:redis) { MockRedis.new }

  after do
    redis.flushall
  end

  describe "#get" do
    context "when data does not exist in redis" do
      it "returns nil" do
        expect(redis_store.get("key")).to eq nil
      end
    end

    context "when data exists in redis" do
      before do
        redis_store.set("key", "val")
      end

      it "returns nil" do
        expect(redis_store.get("key")).to eq "val"
      end
    end
  end

  describe "#set" do
    it "sets data to redis" do
      expect(redis_store.set("key", "val", ttl: 24 * 3600)).to eq true
      expect(redis_store.get("key")).to eq "val"
    end
  end

  describe "#exists" do
    context "when data does not exist in redis" do
      it "returns nil" do
        expect(redis_store.exists("key")).to eq false
      end
    end

    context "when data exists in redis" do
      before do
        redis_store.set("key", "val")
      end

      it "returns nil" do
        expect(redis_store.exists("key")).to eq true
      end
    end
  end
end
