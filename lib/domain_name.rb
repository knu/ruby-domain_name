# -*- coding: utf-8 -*-
#
# domain_name.rb - Domain Name manipulation library for Ruby
#
# Copyright (C) 2011 Akinori MUSHA, All rights reserved.
#

require 'domain_name/punycode'
require 'domain_name/etld_data'
require 'unf'
require 'ipaddr'

# Represents a domain name ready for extracting its registered domain
# and TLD.
class DomainName
  # The full host name normalized, ASCII-ized and downcased using the
  # Unicode NFC rules and the Punycode algorithm.  If initialized with
  # an IP address, the string representation of the IP address
  # suitable for opening a connection to.
  attr_reader :hostname

  # The least "universally original" domain part of this domain name.
  # For example, "example.co.uk" for "www.sub.example.co.uk".
  attr_reader :domain

  # The TLD part of this domain name.  For example, if the hostname is
  # "www.sub.example.co.uk", the TLD part is "uk".  This property is
  # nil only if +ipaddr?+ is true.
  attr_reader :tld

  # Returns an IPAddr object if this is an IP address.
  attr_reader :ipaddr

  # Returns true if this is an IP address, such as "192.168.0.1" and
  # "[::1]".
  def ipaddr?
    @ipaddr ? true : false
  end

  # Returns a host name representation suitable for use in the host
  # name part of a URI.  A host name, an IPv4 address, or a IPv6
  # address enclosed in square brackets.
  attr_reader :uri_host

  # Returns true if this domain name has a canonical TLD.
  def canonical_tld?
    @canonical_tld_p
  end

  # Returns true if this domain name has a canonical registered
  # domain.
  def canonical?
    @canonical_tld_p && (@domain ? true : false)
  end

  DOT = '.'.freeze	# :nodoc:

  # Parses _hostname_ into a DomainName object.  An IP address is also
  # accepted.  An IPv6 address may be enclosed in square brackets.
  def initialize(hostname)
    if hostname.start_with?(DOT)
      raise ArgumentError, "domain name must not start with a dot: #{hostname}"
    end
    case hostname
    when /\A([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\z/
      @ipaddr = IPAddr.new($1)
      @uri_host = @hostname = @ipaddr.to_s
      @domain = @tld = nil
      return
    when /\A([0-9A-Fa-f:]*:[0-9A-Fa-f:]*:[0-9A-Fa-f:]*)\z/,
      /\A\[([0-9A-Fa-f:]*:[0-9A-Fa-f:]*:[0-9A-Fa-f:]*)\]\z/
      @ipaddr = IPAddr.new($1)
      @hostname = @ipaddr.to_s
      @uri_host = "[#{@hostname}]"
      @domain = @tld = nil
      return
    end
    @ipaddr = nil
    @hostname = DomainName.normalize(hostname)
    @uri_host = @hostname
    if last_dot = @hostname.rindex(DOT)
      @tld = @hostname[(last_dot + 1)..-1]
    else
      @tld = @hostname
    end
    etld_data = DomainName.etld_data
    if @canonical_tld_p = etld_data.key?(@tld)
      subdomain = domain = nil
      parent = @hostname
      loop {
        case etld_data[parent]
        when 0
          @domain = domain if domain
          return
        when -1
          @domain = subdomain if subdomain
          return
        when 1
          @domain = parent
          return
        end
        subdomain = domain
        domain = parent
        pos = @hostname.index(DOT, -domain.length) or break
        parent = @hostname[(pos + 1)..-1]
      }
    else
      # unknown/local TLD
      if last_dot
        # fallback - accept cookies down to second level
        # cf. http://www.dkim-reputation.org/regdom-libs/
        if penultimate_dot = @hostname.rindex(DOT, last_dot - 1)
          @domain = @hostname[(penultimate_dot + 1)..-1]
        else
          @domain = @hostname
        end
      else
        # no domain part - must be a local hostname
        @domain = @tld
      end
    end
  end

  # Checks if the server represented by _domain_ is qualified to send
  # and receive cookies for _domain_.
  def cookie_domain?(domain)
    domain = DomainName.new(domain) unless DomainName === domain
    if ipaddr?
      # RFC 6265 #5.1.3
      # Do not perform subdomain matching against IP addresses.
      @hostname == domain.hostname
    else
      # RFC 6265 #4.1.1
      # Domain-value must be a subdomain.
      @domain && self <= domain && domain <= @domain ? true : false
    end
  end

  def ==(other)
    other = DomainName.new(other) unless DomainName === other
    other.hostname == @hostname
  end

  def <=>(other)
    other = DomainName.new(other) unless DomainName === other
    othername = other.hostname
    if othername == @hostname
      0
    elsif @hostname.end_with?(othername) && @hostname[-othername.size - 1, 1] == DOT
      # The other is higher
      -1
    elsif othername.end_with?(@hostname) && othername[-@hostname.size - 1, 1] == DOT
      # The other is lower
      1
    else
      nil
    end
  end

  def <(other)
    case self <=> other
    when -1
      true
    when nil
      nil
    else
      false
    end
  end

  def >(other)
    case self <=> other
    when 1
      true
    when nil
      nil
    else
      false
    end
  end

  def <=(other)
    case self <=> other
    when -1, 0
      true
    when nil
      nil
    else
      false
    end
  end

  def >=(other)
    case self <=> other
    when 1, 0
      true
    when nil
      nil
    else
      false
    end
  end

  def to_s
    @hostname
  end

  alias to_str to_s

  def inspect
    str = '#<%s:%s' % [self.class.name, @hostname]
    if @ipaddr
      str << ' (ipaddr)'
    else
      str << ' domain=' << @domain if @domain
      str << ' tld=' << @tld if @tld
    end
    str << '>'
  end

  class << self
    # Normalizes a _domain_ using the Punycode algorithm as necessary.
    # The result will be a downcased, ASCII-only string.
    def normalize(domain)
      DomainName::Punycode.encode_hostname(domain.chomp(DOT).to_nfc).downcase
    end
  end
end

# Short hand for DomainName.new().
def DomainName(hostname)
  DomainName.new(hostname)
end
