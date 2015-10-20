# coding: utf-8

# 123.m2.K_W のように書けるようにします。
# 123.cP.mPa.s のように単位の換算(cP -> mPa.s)も可能です。
# method_missing をオーバーライドします。

require 'numeric_with_unit'

class NumericWithUnit
  def method_missing(name, *args)
    if args.empty?
      unit_str = name.to_s.gsub('_', '/')
      resolve_unit_chain(Unit[unit_str])
    else
      raise Unit::NoUnitError
    end
  rescue Unit::NoUnitError
    super
  end
  
  attr_writer :unit_chain
  protected :unit_chain=
  
  private
  def resolve_unit_chain(unit)
    unit_chain = @unit_chain || []
    unit_chain.map!{|nwu, chained_unit| [nwu, chained_unit * unit]}
    unit_chain << [self, unit]
    
    if i = unit_chain.index{|nwu, chained_unit| nwu.unit.dimension_equal? chained_unit}
      nwu, chained_unit = *unit_chain[i]
      nwu.convert(chained_unit)
    else
      newnwu = self.class.new(@value, @unit*unit)
      newnwu.unit_chain = unit_chain
      newnwu
    end
  end
end


class NumericWithUnit
  module NumUtil
    def method_missing(name, *args)
      if args.empty?
        unit_str = name.to_s.gsub('_', '/')
        self.to_f.to_nwu(unit_str) # util2は利便性優先なのでto_fしてしまいます
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
