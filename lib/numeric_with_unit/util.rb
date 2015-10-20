# coding: utf-8

# 1234['m3/kg']のように書けるようにします。
# Numeric#[]、Fixnum#[]、Bignum#[]をオーバーライドします。

require 'numeric_with_unit'

class NumericWithUnit
  module NumUtil
    def [](unit)
      NumericWithUnit.new(self, unit)
    end
  end
end

class Fixnum
  prepend NumericWithUnit::NumUtil
end

class Bignum
  prepend NumericWithUnit::NumUtil
end

class Numeric
  prepend NumericWithUnit::NumUtil
end

