
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gpueater/version"

Gem::Specification.new do |spec|
  spec.name          = "gpueater"
  spec.version       = GPUEater::VERSION
  spec.authors       = ["Pegara, Inc."]
  spec.email         = ["info@pegara.com"]

  spec.summary       = %q{GPUEater API Console}
  spec.description   = %q{This module is API for GPUEater web console.}
  spec.homepage      = "https://www.gpueater.com/"
  spec.license       = "MIT"

  # # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "https://www.gpueater.com'"
  # else
  #   raise "RubyGems 2.x or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "faraday", "~> 0.15.2"
  spec.add_dependency "net-http-persistent", "~> 3.0.0"
end
