require 'bundler/gem_tasks'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
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
  version = DomainName::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "domain_name #{version}"
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include(Bundler::GemHelper.gemspec.extra_rdoc_files)
end
