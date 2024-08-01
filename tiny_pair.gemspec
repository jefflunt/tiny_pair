Gem::Specification.new do |s|
  s.name        = "tiny_pair"
  s.version     = "1.0.0"
  s.description = "a tiny pair programming gem that uses an LLM"
  s.summary     = "a tiny pair programming gem that uses an LLM"
  s.authors     = ["Jeff Lunt"]
  s.email       = "jefflunt@gmail.com"
  s.files       = ["lib/tiny_pair.rb"]
  s.homepage    = "https://github.com/jefflunt/tiny_pair"
  s.license     = "MIT"
  s.add_runtime_dependency "tiny_gemini", [">= 0"]
end
