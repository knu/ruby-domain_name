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
      ['COM', nil],
      ['example.COM', 'example.com'],
      ['WwW.example.COM', 'example.com'],
      # Unlisted TLD.
      ['example', 'example'],
      ['example.example', 'example.example'],
      ['b.example.example', 'example.example'],
      ['a.b.example.example', 'example.example'],
      # Listed, but non-Internet, TLD.
      ['local', 'local'],
      ['example.local', 'example.local'],
      ['b.example.local', 'example.local'],
      ['a.b.example.local', 'example.local'],
      # TLD with only 1 rule.
      ['biz', nil],
      ['domain.biz', 'domain.biz'],
      ['b.domain.biz', 'domain.biz'],
      ['a.b.domain.biz', 'domain.biz'],
      # TLD with some 2-level rules.
      ['com', nil],
      ['example.com', 'example.com'],
      ['b.example.com', 'example.com'],
      ['a.b.example.com', 'example.com'],
      ['uk.com', nil],
      ['example.uk.com', 'example.uk.com'],
      ['b.example.uk.com', 'example.uk.com'],
      ['a.b.example.uk.com', 'example.uk.com'],
      ['test.ac', 'test.ac'],
      # TLD with only 1 (wildcard) rule.
      ['cy', nil],
      ['c.cy', nil],
      ['b.c.cy', 'b.c.cy'],
      ['a.b.c.cy', 'b.c.cy'],
      # More complex TLD.
      ['jp', nil],
      ['test.jp', 'test.jp'],
      ['www.test.jp', 'test.jp'],
      ['ac.jp', nil],
      ['test.ac.jp', 'test.ac.jp'],
      ['www.test.ac.jp', 'test.ac.jp'],
      ['kyoto.jp', nil],
      ['c.kyoto.jp', nil],
      ['b.c.kyoto.jp', 'b.c.kyoto.jp'],
      ['a.b.c.kyoto.jp', 'b.c.kyoto.jp'],
      ['pref.kyoto.jp', 'pref.kyoto.jp'],	# Exception rule
      ['www.pref.kyoto.jp', 'pref.kyoto.jp'],	# Exception rule.
      ['city.kyoto.jp', 'city.kyoto.jp'],	# Exception rule.
      ['www.city.kyoto.jp', 'city.kyoto.jp'],	# Exception rule.
      # TLD with a wildcard rule and exceptions.
      ['om', nil],
      ['test.om', nil],
      ['b.test.om', 'b.test.om'],
      ['a.b.test.om', 'b.test.om'],
      ['songfest.om', 'songfest.om'],
      ['www.songfest.om', 'songfest.om'],
      # US K12.
      ['us', nil],
      ['test.us', 'test.us'],
      ['www.test.us', 'test.us'],
      ['ak.us', nil],
      ['test.ak.us', 'test.ak.us'],
      ['www.test.ak.us', 'test.ak.us'],
      ['k12.ak.us', nil],
      ['test.k12.ak.us', 'test.k12.ak.us'],
      ['www.test.k12.ak.us', 'test.k12.ak.us'],
    ].each { |hostname, domain|
      dn = DomainName.new(hostname)
      assert_equal(domain, dn.domain)
    }
  end
end
