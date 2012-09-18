# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'domain_name/version'

Gem::Specification.new do |gem|
  gem.name          = "domain_name"
  gem.version       = DomainName::VERSION
  gem.authors       = ["Akinori MUSHA"]
  gem.email         = ["knu@idaemons.org"]
  gem.description   = <<-'EOS'
This is a Domain Name manipulation library for Ruby.

It can also be used for cookie domain validation based on the Public
Suffix List.
  EOS
  gem.summary       = %q{Domain Name manipulation library for Ruby}
  gem.homepage      = "https://github.com/knu/ruby-domain_name"
  gem.licenses      = ["BSD + MPL 1.1/GPL 2.0/LGPL 2.1"]

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]

  gem.add_runtime_dependency("unf", ["~> 0.0.3"])
  gem.add_development_dependency("shoulda", [">= 0"])
  gem.add_development_dependency("bundler", ["~> 1.2.0"])
  gem.add_development_dependency("rdoc", [">= 2.4.2"])
end
