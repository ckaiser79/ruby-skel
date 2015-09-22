
# coding: utf-8
lib = File.expand_path('lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "<%= @name %>"
  spec.version       = '1.0'
  spec.authors       = ["Christian Kaiser"]
  spec.email         = ["ckaiser@gmx.org"]
  spec.summary       = %q{Short summary of your project}
  spec.description   = %q{Longer description of your project.}
  spec.homepage      = "https://github.com/ckaiser79/"
  spec.license       = "MIT"

  spec.files         = ['lib/<%= @name %>.rb']
  spec.executables   = ['bin/<%= @name %>']
  spec.test_files    = ['spec/<%= @name %>_spec.rb']
  spec.require_paths = ["lib"]
  
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"  
end
