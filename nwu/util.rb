
require 'nwu'

class Fixnum
  def [](unit)
    NumericWithUnit[self, unit]
  end
end

class Bignum
  def [](unit)
    NumericWithUnit[self, unit]
  end
end

class Numeric
  def [](unit)
    NumericWithUnit[self, unit]
  end
end

