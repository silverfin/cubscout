
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cubscout/version"

Gem::Specification.new do |spec|
  spec.name          = "cubscout"
  spec.version       = Cubscout::VERSION
  spec.authors       = ["Joren De Groof", "Fabien Loup"]
  spec.email         = ["joren@silverfin.com", "fabien@silverfin.com"]

  spec.summary       = %q{Help Scout api v2 wrapper}
  spec.description   = %q{Help Scout api v2 wrapper}
  spec.homepage      = "https://www.helpscout.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/GetSilverfin/cubscout"
    spec.metadata["changelog_uri"] = "https://github.com/GetSilverfin/cubscout"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "oauth2", "~>1.4"
  spec.add_runtime_dependency "faraday"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.12"
  spec.add_development_dependency "webmock", "~> 3.5"
end
