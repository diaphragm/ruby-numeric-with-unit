# coding: utf-8

# 1234['m3/kg']のように書けるようにします。
# Numeric#[]、Integer#[](ruby2.4以降)、Fixnum#[](ruby2.4未満)、Bignum#[](ruby2.4未満)をオーバーライドします。

require 'numeric_with_unit'

class NumericWithUnit
  module NumUtil
    def [](unit)
      NumericWithUnit.new(self, unit)
    end
  end
end

if RUBY_VERSION >= "2.4.0"
  Integer.prepend NumericWithUnit::NumUtil
else
  Fixnum.prepend NumericWithUnit::NumUtil
  Bignum.prepend NumericWithUnit::NumUtil
end

Numeric.prepend NumericWithUnit::NumUtil
