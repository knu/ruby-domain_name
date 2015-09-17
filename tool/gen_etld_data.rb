#!/usr/bin/env ruby

require 'rubygems'
require 'pathname'
$basedir = Pathname.new(__FILE__).dirname.parent
$LOAD_PATH.unshift $basedir + 'lib'
require 'domain_name'
require 'set'
require 'erb'
require 'yaml'

def main
  dat_file      = $basedir.join('data', 'effective_tld_names.dat')
  yaml_file     = $basedir.join('lib', 'data', 'etld.yaml')
  marshall_file = $basedir.join('lib', 'cache', 'etld')

  etld_data_date = File.mtime(dat_file)

  File.open(dat_file, 'r:utf-8') do |dat|
    etld_data = { 'data_date' => etld_data_date, 'data' => parse(dat) }

    File.open(yaml_file, 'w:utf-8') do |yaml|
      YAML.dump(etld_data, yaml)
    end

    File.open(marshall_file, 'w+') do |cache|
      cache.write Marshal.dump(etld_data)
    end
  end
end

def normalize_hostname(domain)
  DomainName.normalize(domain)
end

def parse(f)
  {}.tap { |table|
    tlds = Set[]
    f.each_line { |line|
      line.sub!(%r{//.*}, '')
      line.strip!
      next if line.empty?
      case line
      when /^local$/
        # ignore .local
        next
      when /^([^!*]+)$/
        domain = normalize_hostname($1)
        value = 0
      when /^\*\.([^!*]+)$/
        domain = normalize_hostname($1)
        value = -1
      when /^\!([^!*]+)$/
        domain = normalize_hostname($1)
        value = 1
      else
        raise "syntax error: #{line}"
      end
      tld = domain.match(/(?:^|\.)([^.]+)$/)[1]
      table[tld] ||= 1
      table[domain] = value
    }
  }
end

main()
