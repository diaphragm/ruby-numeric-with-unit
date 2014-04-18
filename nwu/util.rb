
# モンキーパッチ的なユーティリティ群

require 'mathn'
require 'nwu'

class NumericWithUnit
  def method_missing(*args)
    unit_str = args.first.to_s.gsub('_', '/')
    unit_chain_util(Unit[unit_str])
  rescue Unit::NoUnitError
    super
  end
  
  attr_writer :unit_chain
  
  private
  def unit_chain_util(unit)
    ucs = @unit_chain || []
    ucs.map!{|nwu, u| [nwu, u * unit]}
    ucs << [self, unit]
    
    uc = ucs.select{|nwu, u|
      nwu.unit.dimension_equal? u
    }.last
    
    if uc
      nwu, nu = *uc
      nwu[nu]
    else
      nnwu = self.class.new(@value, @unit*unit)
      nnwu.unit_chain = ucs
      nnwu
    end
  end
end

class NumericWithUnit
  module NumUtil
    def [](unit)
      NumericWithUnit[self.rationalize, unit] # ratoinalize
    end
    
    def method_missing(*args)
      unit_str = args.first.to_s.gsub('_', '/')
      self[unit_str]
    rescue Unit::NoUnitError
      super
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



# Monkey Patch
class NumericWithUnit
  def inspect
    "#{@value.to_f} [#{@unit.symbol}] #{unit.dimension}"
  end
end
