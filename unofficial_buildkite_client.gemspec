
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "unofficial_buildkite_client/version"

Gem::Specification.new do |spec|
  spec.name          = "unofficial_buildkite_client"
  spec.version       = UnofficialBuildkiteClient::VERSION
  spec.authors       = ["Fumiaki MATSUSHIMA"]
  spec.email         = ["mtsmfm@gmail.com"]

  spec.summary       = %q{Unofficial Buildkite API client}
  spec.description   = %q{Unofficial Buildkite API client}
  spec.homepage      = "https://github.com/mtsmfm/unofficial_buildkite_client"
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
  spec.add_development_dependency "rake", "~> 10.0"
end
