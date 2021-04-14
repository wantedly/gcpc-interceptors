
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gcpc/interceptors/version"

Gem::Specification.new do |spec|
  spec.name          = "gcpc-interceptors"
  spec.version       = Gcpc::Interceptors::VERSION
  spec.authors       = ["Nao Minami"]
  spec.email         = ["south37777@gmail.com"]

  spec.summary       = %q{The collection of interceptors for gcpc (Google Cloud Pub/Sub Client for Ruby)}
  spec.description   = %q{The collection of interceptors for gcpc (Google Cloud Pub/Sub Client for Ruby)}
  spec.homepage      = "https://github.com/wantedly/gcpc-interceptors"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "mock_redis", "~> 0.20"
  spec.add_runtime_dependency "gcpc"
end
