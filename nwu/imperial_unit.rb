
require 'nwu/base_unit'

Unit << Unit.new do |conf|
  conf.symbol = 'ft'
  conf.dimension[:L] = 1
  conf.from_si = ->(x){x/0.3048}
  conf.to_si = -> (x){x*0.3048}
end

Unit['degR'] = 9/5, 'K'

Unit << Unit.new do |conf|
  deg_r = Unit['degR']
  conf.symbol = '℉'
  conf.dimension = deg_r.dimension
  conf.from_si = ->(x){(deg_r.from_si(x)) - 459.67}
  conf.to_si = ->(x){deg_r.to_si(x + 459.67)}
end
Unit['degF'] = '℉'
