$: << File.expand_path('../lib', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "audit_trail"
  spec.version       = "0.0.1"
  spec.authors       = ["Kevin Buchanan"]
  spec.email         = ["kevaustinbuch@gmail.com"]
  spec.summary       = %q{Tracks change history on ActiveRecord models}

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
