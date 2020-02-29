lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-dry"
  spec.version       = Jekyll::JekyllDry::VERSION
  spec.authors       = ["vduseev"]
  spec.email         = ["vagiz.d@gmail.com"]

  spec.summary       = %q{Don't Repeat Yourself. Reuse text fragments.}
  spec.description   = %q{Jekyll plugin that helps you to implement the DRY (Don't Repeat Yourself) principle while writing documentation using Jekyll.}
  spec.homepage      = "https://github.com/vduseev/jekyll-dry" 
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vduseev/jekyll-dry"
  spec.metadata["changelog_uri"] = "https://raw.githubusercontent.com/vduseev/jekyll-dry/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
