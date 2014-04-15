
require 'nwu'

class NumericWithUnit
  def method_missing(*args)
    unit = args.first.to_s.gsub('_', '/')
    begin
      @unit *= Unit[unit]
      self
    rescue Unit::NoUnitError
      super
    end
  end
end

class NumericWithUnit
  module NumUtil
    def to_nwu(unit)
      NumericWithUnit[self, unit]
    end
    alias :[] :to_nwu
    
    def method_missing(*args)
      unit = args.first.to_s.gsub('_', '/')
      begin
        NumericWithUnit[self, unit]
      rescue Unit::NoUnitError
        super
      end
    end
  end
  
  module StrUtil
    def to_nwu(mthd=:to_r)
      m = self.match /(?<value>.+) (?<unit>.+)/
      NumericWithUnit[m[:value].__send__(mthd), m[:unit]]
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


class String
  prepend NumericWithUnit::StrUtil
end
