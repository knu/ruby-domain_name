#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'pathname'
$basedir = Pathname.new(__FILE__).dirname.parent
$LOAD_PATH.unshift $basedir + 'lib'
require 'erb'

def main
  dat_file = $basedir + 'data' + 'UnicodeData.txt'
  dir      = $basedir + 'lib' + 'domain_name'
  erb_file = dir + 'unicode_autogen.rb.erb'
  rb_file  = dir + 'unicode_autogen.rb'

  File.open(dat_file, 'r:utf-8') { |dat|
    combining, bidi_hash = parse(dat)
    File.open(rb_file, 'w:utf-8') { |rb|
      File.open(erb_file, 'r:utf-8') { |erb|
        rb.print ERB.new(erb.read).result(binding)
      }
    }
  }
end

def parse(f)
  [[], {}].tap { |combining, bidi_hash|
    beg_combining = beg_bidi = last_bidi = last = nil
    f.each_line { |line|
      line.strip!
      fields = line.split(';')
      cp = fields[0].to_i(16)

      case gc = fields[2]
      when /^(?:Mn|Mc|Me)$/
        beg_combining ||= cp
      else
        if beg_combining
          combining << (beg_combining == last ? beg_combining : beg_combining..last)
          beg_combining = nil	# cp is not a combining character
        end
      end

      bidi = fields[4].to_sym
      beg_bidi ||= cp
      if last_bidi && bidi != last_bidi
        (bidi_hash[bidi] ||= []) << (beg_bidi == last ? beg_bidi : beg_bidi..last)
        beg_bidi = cp
      end

      last = cp
      last_bidi = bidi
    }

    if beg_combining
      combining << (beg_combining == last ? beg_combining : beg_combining..last)
    end

    if last_bidi
      (bidi_hash[last_bidi] ||= []) << (beg_bidi == last ? beg_bidi : beg_bidi..last)
    end
  }
end

main()
