# -*- coding: utf-8 -*-
#
# punycode.rb - PunyCode encoder for the Domain Name library
#
# Copyright (C) 2011, 2012 Akinori MUSHA, All rights reserved.
#
# Ported from puny.c, a part of VeriSign XCode (encode/decode) IDN
# Library.
#
# Copyright (C) 2000-2002 Verisign Inc., All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
#  1) Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  2) Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#
#  3) Neither the name of the VeriSign Inc. nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# This software is licensed under the BSD open source license. For more
# information visit www.opensource.org.
#
# Authors:
#  John Colosi (VeriSign)
#  Srikanth Veeramachaneni (VeriSign)
#  Nagesh Chigurupati (Verisign)
#  Praveen Srinivasan(Verisign)

class DomainName
  module Punycode
    BASE = 36
    TMIN = 1
    TMAX = 26
    SKEW = 38
    DAMP = 700
    INITIAL_BIAS = 72
    INITIAL_N = 0x80
    DELIMITER = '-'

    # The maximum value of an DWORD variable
    MAXINT = (1 << 32) - 1

    # Used in the calculation of bias:
    LOBASE = BASE - TMIN

    # Used in the calculation of bias:
    CUTOFF = LOBASE * TMAX / 2

    RE_NONBASIC = /[^\x00-\x7f]/

    # Most errors we raise are basically kind of ArgumentError.
    class ArgumentError < ::ArgumentError; end
    class BufferOverflowError < ArgumentError; end

    # Returns the basic code point whose value (when used for
    # representing integers) is d, which must be in the range 0 to
    # BASE-1.  The lowercase form is used unless flag is true, in
    # which case the uppercase form is used.  The behavior is
    # undefined if flag is nonzero and digit d has no uppercase form.
    def encode_digit(d, flag)
      (d + 22 + (d < 26 ? 75 : 0) - (flag ? (1 << 5) : 0)).chr
      #  0..25 map to ASCII a..z or A..Z
      # 26..35 map to ASCII 0..9
    end
    module_function :encode_digit

    # Main encode function
    def encode(string)
      input = string.unpack('U*')
      output = ''

      # Initialize the state
      n = INITIAL_N
      delta = 0
      bias = INITIAL_BIAS

      # Handle the basic code points
      input.each { |cp| output << cp.chr if cp < 0x80 }

      h = b = output.length

      # h is the number of code points that have been handled, b is the
      # number of basic code points, and out is the number of characters
      # that have been output.

      output << DELIMITER if b > 0

      # Main encoding loop

      while h < input.length
        # All non-basic code points < n have been handled already.  Find
        # the next larger one

        m = MAXINT
        input.each { |cp|
          m = cp if (n...m) === cp
        }

        # Increase delta enough to advance the decoder's <n,i> state to
        # <m,0>, but guard against overflow

        delta += (m - n) * (h + 1)
        raise BufferOverflowError if delta > MAXINT
        n = m

        input.each { |cp|
          # AMC-ACE-Z can use this simplified version instead
          if cp < n
            delta += 1
            raise BufferOverflowError if delta > MAXINT
          elsif cp == n
            # Represent delta as a generalized variable-length integer
            q = delta
            k = BASE
            loop {
              t = k <= bias ? TMIN : k - bias >= TMAX ? TMAX : k - bias
              break if q < t
              q, r = (q - t).divmod(BASE - t)
              output << encode_digit(t + r, false)
              k += BASE
            }

            output << encode_digit(q, false)

            # Adapt the bias
            delta = h == b ? delta / DAMP : delta >> 1
            delta += delta / (h + 1)
            bias = 0
            while delta > CUTOFF
              delta /= LOBASE
              bias += BASE
            end
            bias += (LOBASE + 1) * delta / (delta + SKEW)

            delta = 0
            h += 1
          end
        }

        delta += 1
        n += 1
      end

      output
    end
    module_function :encode

    def encode_hostname(hostname)
      hostname.match(RE_NONBASIC) or return hostname

      hostname.split('.').map { |name|
        if name.match(RE_NONBASIC)
          'xn--' << encode(name)
        else
          name
        end
      }.join('.')
    end
    module_function :encode_hostname
  end
end
