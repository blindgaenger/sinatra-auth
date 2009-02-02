Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "sinatra-auth"
  s.version = "0.1"
  s.date = "2009-02-01"
  s.authors = ["blindgaenger"]
  s.email = "blindgaenger@gmail.com"
  s.homepage = "http://github.com/blindgaenger/sinatra-auth"
  s.summary = "use the basic HTTP authentication of rack in your sinatra application"

  s.files = [
    "Rakefile",
    "README.textile",
    "lib/auth.rb",
    "spec/auth_spec.rb",
    "examples/simple.erb"
  ]
  s.require_paths = ["lib"]
  s.add_dependency "sinatra", [">= 0.3.2"]

  s.has_rdoc = "false"
end

