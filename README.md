# Gcpc::Interceptors

Gcpc::Interceptors is a collection of interceptors for [gcpc](https://github.com/wantedly/gcpc).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gcpc-interceptors'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gcpc-interceptors

## Usage

### Interceptors for Publisher

```ruby
require "gcpc"
require "gcpc/interceptors"

publisher = Gcpc::Publisher.new(
  project_id:    "project-example-1",
  topic:         "topic-example-1",
  interceptors:  [
    Gcpc::Publisher::Interceptors::EncodeInterceptor.new(
      content_type: :json
    ),
    Gcpc::Interceptors::Publisher::IdInterceptor.new,
    Gcpc::Interceptors::Publisher::PublisherNameInterceptor.new(
      publisher: "publisher-A"
    ),
    Gcpc::Interceptors::Publisher::TimestampInterceptor.new,
  ]
  emulator_host: "localhost:8085",
)

jsondata = { key: :value }
attributes = {}
publisher.publish(jsondata, attributes)  # published as `{"key":"value"}`, {"published_by":"publisher-A","published_at":"2019-03-01T00:00:00+00:00"}
```

### Interceptors for Subscriber

```ruby
require "gcpc"
require "gcpc/interceptors"

class LogHandler < Gcpc::Subscriber::BaseHandler
  LOGGER = Logger.new(STDOUT)

  def handle(data, attributes, message)
    LOGGER.info "#{message.inspect}"
    LOGGER.info "data: #{data}"
    LOGGER.info "attributes: #{attributes}"
  end
end

redis_store = Gcpc::Interceptors::Utils::RedisStore.new(redis: Redis.new(ENV["REDIS_URL"]))

class RaiseExceptionStrategy < Gcpc::Interceptors::Subscriber::CheckOrderInterceptor::BaseStrategy
  def on_swapped(data, attributes, message, &block)
    raise "Swapped!"
  end
end

subscriber = Gcpc::Subscriber.new(
  project_id:    "project-example-1",
  subscription:  "topic-example-1",
  interceptors:  [
    Gcpc::Interceptors::Subscriber::DecodeInterceptor.new(
      strategy: Gcpc::Interceptors::Subscriber::DecodeInterceptor::JSONStrategy.new,
    ),
    Gcpc::Interceptors::Subscriber::CheckDupInterceptor.new(
      store: redis_store,
    ),
    Gcpc::Interceptors::Subscriber::CheckOrderInterceptor.new(
      store:    redis_store,
      strategy: RaiseExceptionStrategy.new,
    ),
  ],
  emulator_host: "localhost:8085",
)
subscriber.handle(LogHandler)

subscriber.run
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wantedly/gcpc-interceptors.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
