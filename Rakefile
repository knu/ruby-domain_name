# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "domain_name"
  gem.homepage = "http://github.com/knu/ruby-domain_name"
  gem.license = "BSD + MPL 1.1/GPL 2.0/LGPL 2.1"
  gem.summary = %Q{Domain Name manipulation library for Ruby}
  gem.description = <<-EOS
This is a Domain Name manipulation library for Ruby.

It can also be used for cookie domain validation based on the Public
Suffix List.
  EOS
  gem.email = "knu@idaemons.org"
  gem.authors = ["Akinori MUSHA"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

task :test => 'lib/domain_name/etld_data.rb'

etld_dat = 'data/effective_tld_names.dat'

file etld_dat do
  require 'open-uri'
  File.open(etld_dat, 'w') { |dat|
    dat.print URI('http://mxr.mozilla.org/mozilla-central/source/netwerk/dns/effective_tld_names.dat?raw=1').read
  }
end

file 'lib/domain_name/etld_data.rb' => [
  etld_dat,
  'lib/domain_name/etld_data.rb.erb',
  'tool/gen_etld_data.rb'
] do
  ruby 'tool/gen_etld_data.rb'
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "domain_name #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
