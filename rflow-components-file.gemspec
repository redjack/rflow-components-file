# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rflow/components/file/version"

Gem::Specification.new do |s|
  s.name        = "rflow-components-file"
  s.version     = RFlow::Components::File::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9'
  s.authors     = ["Michael L. Artz"]
  s.email       = ["michael.artz@redjack.com"]
  s.homepage    = "https://github.com/redjack/rflow-components-file"
  s.license     = "Apache-2.0"
  s.summary     = %q{Components that operate on files for the RFlow FBP framework}
  s.description = %q{Components that operate on files for the RFlow FBP framework.  Also includes the File schema}

  s.rubyforge_project = "rflow-components-file"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.bindir        = 'bin'

  s.add_dependency 'rflow', '~> 1.2'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  s.add_development_dependency 'rake', '>= 10.3'
end
