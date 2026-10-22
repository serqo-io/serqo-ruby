Gem::Specification.new do |spec|
  spec.name = "serqo"
  spec.version = "0.1.0"
  spec.summary = "Official Ruby client for the Serqo Search API"
  spec.description = "A dependency-free HTTP client for the public Serqo Search API."
  spec.authors = ["Serqo"]
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"
  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]
  spec.metadata["homepage_uri"] = "https://serqo.io"
  spec.metadata["source_code_uri"] = "https://github.com/serqo-io/serqo-ruby"
end
