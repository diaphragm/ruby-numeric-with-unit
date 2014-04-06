
# 
# 独断と偏見による
# 

require 'nwu/base_unit'

# Length
Unit['Å'] = 1e-10, 'm'

# Area
Unit['b'] = 1e-28, 'm2'

# Pressure
Unit['bar'] = 1e5, 'Pa'
Unit['atm'] = 101325, 'Pa'

# Speed
Unit['kph'] = 'km/hr'

# Ratio
Unit << Unit.new do |conf|
  conf.symbol = '%'
  conf.from_si{|x| x*100}
  conf.to_si{|x| x/100}
end
Unit << Unit.new do |conf|
  conf.symbol = '‰'
  conf.from_si{|x| x*1000}
  conf.to_si{|x| x/1000}
end
Unit << Unit.new do |conf|
  conf.symbol = 'ppm'
  conf.from_si{|x| x*1e6}
  conf.to_si{|x| x/1e6}
end
Unit << Unit.new do |conf|
  conf.symbol = 'ppb'
  conf.from_si{|x| x*1e9}
  conf.to_si{|x| x/1e9}
end
