# coding: utf-8

require 'numeric_with_unit'

class Fixnum
  def to_nwu(unit)
    NumericWithUnit.new(self, unit)
  end
end

class Bignum
  def to_nwu(unit)
    NumericWithUnit.new(self, unit)
  end
end

class Numeric
  def to_nwu(unit)
    NumericWithUnit.new(self, unit)
  end
end

class String
  def to_nwu(mthd=:to_r)
    # TODO: 適当なのでもう少しいい感じに。いい感じに
    m = self.match /.*?(?=[\s\(\[])/
    value = m.to_s
    unit = m.post_match.strip.gsub(/^\[|\]$/, '')
    NumericWithUnit.new(value.__send__(mthd), unit)
  end
end

