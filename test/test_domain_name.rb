require 'helper'

class TestDomainName < Test::Unit::TestCase
  should "raise ArgumentError if hostname starts with a dot" do
    [
      # Leading dot.
      '.com',
      '.example',
      '.example.com',
      '.example.example',
    ].each { |hostname|
      assert_raises(ArgumentError) { DomainName.new(hostname) }
    }
  end

  should "parse canonical domain names correctly" do
    [
      # Mixed case.
      ['COM', nil, false, 'com', true],
      ['example.COM', 'example.com', true, 'com', true],
      ['WwW.example.COM', 'example.com', true, 'com', true],
      # Unlisted TLD.
      ['example', 'example', false, 'example', false],
      ['example.example', 'example.example', false, 'example', false],
      ['b.example.example', 'example.example', false, 'example', false],
      ['a.b.example.example', 'example.example', false, 'example', false],
      # Listed, but non-Internet, TLD.
      ['local', 'local', false, 'local', false],
      ['example.local', 'example.local', false, 'local', false],
      ['b.example.local', 'example.local', false, 'local', false],
      ['a.b.example.local', 'example.local', false, 'local', false],
      # TLD with only 1 rule.
      ['biz', nil, false, 'biz', true],
      ['domain.biz', 'domain.biz', true, 'biz', true],
      ['b.domain.biz', 'domain.biz', true, 'biz', true],
      ['a.b.domain.biz', 'domain.biz', true, 'biz', true],
      # TLD with some 2-level rules.
      ['com', nil, false, 'com', true],
      ['example.com', 'example.com', true, 'com', true],
      ['b.example.com', 'example.com', true, 'com', true],
      ['a.b.example.com', 'example.com', true, 'com', true],
      ['uk.com', nil, false, 'com', true],
      ['example.uk.com', 'example.uk.com', true, 'com', true],
      ['b.example.uk.com', 'example.uk.com', true, 'com', true],
      ['a.b.example.uk.com', 'example.uk.com', true, 'com', true],
      ['test.ac', 'test.ac', true, 'ac', true],
      # TLD with only 1 (wildcard) rule.
      ['cy', nil, false, 'cy', true],
      ['c.cy', nil, false, 'cy', true],
      ['b.c.cy', 'b.c.cy', true, 'cy', true],
      ['a.b.c.cy', 'b.c.cy', true, 'cy', true],
      # More complex TLD.
      ['jp', nil, false, 'jp', true],
      ['test.jp', 'test.jp', true, 'jp', true],
      ['www.test.jp', 'test.jp', true, 'jp', true],
      ['ac.jp', nil, false, 'jp', true],
      ['test.ac.jp', 'test.ac.jp', true, 'jp', true],
      ['www.test.ac.jp', 'test.ac.jp', true, 'jp', true],
      ['kyoto.jp', nil, false, 'jp', true],
      ['c.kyoto.jp', nil, false, 'jp', true],
      ['b.c.kyoto.jp', 'b.c.kyoto.jp', true, 'jp', true],
      ['a.b.c.kyoto.jp', 'b.c.kyoto.jp', true, 'jp', true],
      ['pref.kyoto.jp', 'pref.kyoto.jp', true, 'jp', true],	# Exception rule
      ['www.pref.kyoto.jp', 'pref.kyoto.jp', true, 'jp', true],	# Exception rule.
      ['city.kyoto.jp', 'city.kyoto.jp', true, 'jp', true],	# Exception rule.
      ['www.city.kyoto.jp', 'city.kyoto.jp', true, 'jp', true],	# Exception rule.
      # TLD with a wildcard rule and exceptions.
      ['om', nil, false, 'om', true],
      ['test.om', nil, false, 'om', true],
      ['b.test.om', 'b.test.om', true, 'om', true],
      ['a.b.test.om', 'b.test.om', true, 'om', true],
      ['songfest.om', 'songfest.om', true, 'om', true],
      ['www.songfest.om', 'songfest.om', true, 'om', true],
      # US K12.
      ['us', nil, false, 'us', true],
      ['test.us', 'test.us', true, 'us', true],
      ['www.test.us', 'test.us', true, 'us', true],
      ['ak.us', nil, false, 'us', true],
      ['test.ak.us', 'test.ak.us', true, 'us', true],
      ['www.test.ak.us', 'test.ak.us', true, 'us', true],
      ['k12.ak.us', nil, false, 'us', true],
      ['test.k12.ak.us', 'test.k12.ak.us', true, 'us', true],
      ['www.test.k12.ak.us', 'test.k12.ak.us', true, 'us', true],
    ].each { |hostname, domain, canonical, tld, canonical_tld|
      dn = DomainName.new(hostname)
      assert_equal(domain, dn.domain)
      assert_equal(canonical, dn.canonical?)
      assert_equal(tld, dn.tld)
      assert_equal(canonical_tld, dn.canonical_tld?)
    }
  end

  should "compare hostnames correctly" do
    [
      ["foo.com", "abc.foo.com", 1],
      ["COM", "abc.foo.com", 1],
      ["abc.def.foo.com", "foo.com", -1],
      ["abc.def.foo.com", "ABC.def.FOO.com", 0],
      ["abc.def.foo.com", "bar.com", nil],
    ].each { |x, y, v|
      dx, dy = DomainName(x), DomainName(y)
      [
        [dx, y, v],
        [dx, dy, v],
        [dy, x, v ? -v : v],
        [dy, dx, v ? -v : v],
      ].each { |a, b, expected|
        assert_equal expected, a <=> b
        case expected
        when 1
          assert_equal(true,  a >  b)
          assert_equal(true,  a >= b)
          assert_equal(false, a == b)
          assert_equal(false, a <= b)
          assert_equal(false, a <  b)
        when -1
          assert_equal(true,  a <  b)
          assert_equal(true,  a <= b)
          assert_equal(false, a == b)
          assert_equal(false, a >= b)
          assert_equal(false, a >  b)
        when 0
          assert_equal(false, a <  b)
          assert_equal(true,  a <= b)
          assert_equal(true,  a == b)
          assert_equal(true,  a >= b)
          assert_equal(false, a >  b)
        when nil
          assert_equal(nil,   a <  b)
          assert_equal(nil,   a <= b)
          assert_equal(false, a == b)
          assert_equal(nil,   a >= b)
          assert_equal(nil,   a >  b)
        end
      }
    }
  end

  should "check cookie domain correctly" do
    [
      ['b.kyoto.jp', 'jp', false],
      ['b.kyoto.jp', 'kyoto.jp', false],
      ['b.kyoto.jp', 'b.kyoto.jp', false],
      ['b.kyoto.jp', 'a.b.kyoto.jp', false],

      ['b.c.kyoto.jp', 'jp', false],
      ['b.c.kyoto.jp', 'kyoto.jp', false],
      ['b.c.kyoto.jp', 'c.kyoto.jp', false],
      ['b.c.kyoto.jp', 'b.c.kyoto.jp', true],
      ['b.c.kyoto.jp', 'a.b.c.kyoto.jp', false],

      ['b.c.d.kyoto.jp', 'jp', false],
      ['b.c.d.kyoto.jp', 'kyoto.jp', false],
      ['b.c.d.kyoto.jp', 'd.kyoto.jp', false],
      ['b.c.d.kyoto.jp', 'c.d.kyoto.jp', true],
      ['b.c.d.kyoto.jp', 'b.c.d.kyoto.jp', true],
      ['b.c.d.kyoto.jp', 'a.b.c.d.kyoto.jp', false],

      ['pref.kyoto.jp', 'jp', false],
      ['pref.kyoto.jp', 'kyoto.jp', false],
      ['pref.kyoto.jp', 'pref.kyoto.jp', true],
      ['pref.kyoto.jp', 'a.pref.kyoto.jp', false],

      ['b.pref.kyoto.jp', 'jp', false],
      ['b.pref.kyoto.jp', 'kyoto.jp', false],
      ['b.pref.kyoto.jp', 'pref.kyoto.jp', true],
      ['b.pref.kyoto.jp', 'b.pref.kyoto.jp', true],
      ['b.pref.kyoto.jp', 'a.b.pref.kyoto.jp', false],
    ].each { |host, domain, expected|
      dn = DomainName(host)
      assert_equal(expected, dn.cookie_domain?(domain))
      assert_equal(expected, dn.cookie_domain?(DomainName(domain)))
      assert_equal(false, dn.ipaddr?)
    }
  end

  should "parse IPv6 addresseses" do
    a = '2001:200:dff:fff1:216:3eff:feb1:44d7'
    b = '2001:0200:0dff:fff1:0216:3eff:feb1:44d7'
    [b, b.upcase, "[#{b}]", "[#{b.upcase}]"].each { |host|
      dn = DomainName(host)
      assert_equal("[#{a}]", dn.uri_host)
      assert_equal(a, dn.hostname)
      assert_equal(true, dn.ipaddr?)
    }
  end
end
