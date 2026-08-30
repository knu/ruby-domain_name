domain_name
===========

Synopsis
--------

Domain Name manipulation library for Ruby

Description
-----------

* Parses a domain name ready for extracting the registered domain and
  TLD.

        require "domain_name"

        host = DomainName("a.b.example.co.uk")
        host.domain         #=> "example.co.uk"
        host.tld            #=> "uk"
        host.cookie_domain?("example.co.uk")    #=> true
        host.cookie_domain?("co.uk")            #=> false

        host = DomainName("[::1]")  # IP addresses like "192.168.1.1" and "::1" are also acceptable
        host.ipaddr?        #=> true
        host.cookie_domain?("0:0:0:0:0:0:0:1")  #=> true

* Implements rudimental IDNA support.

To-do's
-------

* Implement IDNA 2008 (and/or 2003) including the domain label
  validation and mapping defined in RFC 5891-5895 and UTS #46.
  (work in progress)

* Define a compact YAML serialization format.

Installation
------------

	gem install domain_name

Release
-------

Releases use `v`-prefixed version tags.  Push the release commit to
`master`, wait for CI to pass, and then push the matching tag.  A
successful tag CI run publishes the gem through RubyGems trusted
publishing and creates the GitHub release.

Before the first automated release, register `knu/ruby-domain_name`,
workflow `publish-gem.yml`, and environment `rubygems.org` as a trusted
publisher at
https://rubygems.org/gems/domain_name/trusted_publishers/new.

References
----------

* [RFC 3492](http://tools.ietf.org/html/rfc3492) (Obsolete; just for test cases)

* [RFC 5890](http://tools.ietf.org/html/rfc5890)

* [RFC 5891](http://tools.ietf.org/html/rfc5891)

* [RFC 5892](http://tools.ietf.org/html/rfc5892)

* [RFC 5893](http://tools.ietf.org/html/rfc5892)

* [Public Suffix List](https://publicsuffix.org/list/)

License
-------

Copyright (c) 2011-2017 Akinori MUSHA

Licensed under the 2-clause BSD license.

Some portion of this library is copyrighted by third parties and
licensed under MPL 2.0 or 3-clause BSD license,
See `LICENSE.txt` for details.
