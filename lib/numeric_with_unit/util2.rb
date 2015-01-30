# coding: utf-8

# 123.m2.K_W のように書けるようにします。
# method_missing をオーバーライドします。

require 'numeric_with_unit'

class NumericWithUnit
  def method_missing(name, *args)
    if args.empty?
      unit_str = name.to_s.gsub('_', '/')
      unit_chain_util(Unit[unit_str])
    else
      raise Unit::NoUnitError
    end
  rescue Unit::NoUnitError
    super
  end
  
  attr_writer :unit_chain
  
  private
  def unit_chain_util(unit)
    ucs = @unit_chain || []
    ucs.map!{|nwu, u| [nwu, u * unit]}
    ucs << [self, unit]
    
    if i = ucs.index{|nwu, u| nwu.unit.dimension_equal? u}
      nwu, nu = *ucs[i]
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
    def method_missing(name, *args)
      if args.empty?
        unit_str = name.to_s.gsub('_', '/')
        self.rationalize.to_nwu(unit_str) # util2は利便性優先なのでratoinalizeしてしまいます
      else
        raise Unit::NoUnitError
      end
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
