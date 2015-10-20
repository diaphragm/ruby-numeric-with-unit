# coding: utf-8

#
# 変換に対応しきれていない単位
# 四則演算を交える場合に要注意
#

require 'numeric_with_unit/unit_definition/base'

class NumericWithUnit
  # Temperature
  Unit << Unit.new do |conf|
    k = Unit['K']
    intercept = "273.15".to_r
    
    conf.symbol = '℃'
    conf.dimension = k.dimension
    conf.from_si{|x| k.from_si(x)-intercept}
    conf.to_si{|x| k.to_si(x+intercept)}
  end
  
  Unit['degC'] = '℃'
  
  Unit << Unit.new do |conf|
    degr = Unit['degR']
    intercept = "459.67".to_r
    
    conf.symbol = 'degF'
    conf.dimension = degr.dimension
    conf.from_si{|x| degr.from_si(x)-intercept}
    conf.to_si{|x| degr.to_si(x+intercept)}
  end
  
  # Pressure
  Unit << Unit.new do |conf|
    pa = Unit['Pa']
    atm = 101325

    conf.symbol = 'PaG'
    conf.dimension = pa.dimension
    conf.from_si{|x| pa.from_si(x)-atm}
    conf.to_si{|x| pa.to_si(x+atm)}
  end
end
