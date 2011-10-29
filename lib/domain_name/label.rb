require 'domain_name/punycode'
require 'domain_name/unicode'

class DomainName
  class Label < String
    def ascii?
      !match(/[^\x00-\x7f]/)
    end

    def ldh?
      !!match(/\A[A-Za-z0-9](?:[A-Za-z0-9\-]{,61}[A-Za-z0-9])?\z/)
    end

    def r_ldh?
      !!match(/\A..--/) && ldh?
    end

    def xn?
      start_with?('xn--') && ldh?
    end

    def a?
      xn? &&
        begin
          DomainName::Punycode.decode(self)
          true
        rescue
          false
        end
    end

    def nr_ldh?
      !match(/\A..--/) && ldh?
    end

    def nfc?
      to_nfc == self
    end

    def u?
      valid_encoding? && !ascii? && nfc? &&
        !match(/\A#{DomainName::Unicode::RE_COMBINING}/o)
      # TODO: BiDi check
    end
  end
end
