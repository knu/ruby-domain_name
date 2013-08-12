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

  gem.add_runtime_dependency("unf", ["< 1.0.0", ">= 0.0.5"])
  gem.add_development_dependency("shoulda", [RUBY_VERSION < "1.9" ? "< 3.5.0" : ">= 0"])
  if RUBY_VERSION < "1.9"
    # Cap dependency on activesupport with < 4.0 on behalf of
    # shoulda-matchers to satisfy bundler.
    gem.add_development_dependency("activesupport", ["< 4.0"])
  end
  gem.add_development_dependency("bundler", [">= 1.2.0"])
  gem.add_development_dependency("rake", [">= 0.9.2.2"])
  gem.add_development_dependency("rdoc", [">= 2.4.2"])
end
