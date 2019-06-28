class FakeHandler
  # @param [String] data
  # @param [Hash] attributes
  # @param [Google::Cloud::Pubsub::ReceivedMessage] message
  def handle(data, attributes, message)
    # Do nothing
  end
end

class FakeMessage
  def initialize(data:, attributes:)
    @data       = data
    @attributes = attributes
  end

  attr_reader :data, :attributes

  def ack!
    # Do nothing
  end

  def nack!
    # Do nothing
  end
end

class FakeStore
  def initialize
    @store = {}
  end

  def get(key)
    @store[key]
  end

  def set(key, val, ttl: nil)
    @store[key] = val
  end

  def exists(key)
    @store.has_key?(key)
  end
end

class FakeLogger
  def initialize
    @messages = {}
  end
  attr_reader :messages

  [:debug, :info, :warn, :error, :fatal].each do |level|
    define_method level do |obj|
      @messages[level] ||= []
      @messages[level] << obj
    end
  end
end
