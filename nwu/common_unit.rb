
# 
# 独断と偏見による
# 

require 'mathn'
require 'nwu/base_unit'

Unit['-'] = '1'

# Time
Unit['day'] = 24, 'hr'
Unit['week'] = 7, 'day'
Unit['month'] = 30, 'day' # 30日固定
Unit['year'] = 12, 'month' # 360日固定

# Mass
Unit['ton'] = 1000, 'kg'
Unit['oz'] = 0.45359237.rationalize, 'kg'
Unit['lb'] = 1/16, 'oz'

# Length
Unit['Å'] = 1e-10, 'm'
Unit['yd'] =  0.9144.rationalize, 'm'
Unit['ft'] = 1/3, 'yd'
Unit['in'] = 1/12, 'ft'
Unit['mi'] = 5280, 'ft'

# Volume
Unit['cc'] = 'cm3'
Unit['bbl'] = 0.158987294928.rationalize, 'm3'

# Force
Unit['kgf'] = 9.80665.rationalize, 'N'

# Pressure
Unit['bar'] = 1e5, 'Pa'
Unit['atm'] = 101325, 'Pa'
Unit['Torr'] = 101325/760, 'Pa'
Unit['mmHg'] = 101325/760, 'Pa'
Unit['mHg'] = 1e-3, 'mmHg' # for compatible
Unit['mH2O'] = 9806.65.rationalize, 'Pa'
Unit['mAq'] = 'mH2O'

# 加算の換算がうまくない
Unit << Unit.new do |conf|
  atm = 101325
  conf.symbol = 'PaG'
  conf.dimension = Unit['Pa'].dimension
  conf.from_si{|x| x - atm}
  conf.to_si{|x| x + atm}
end

# Speed
Unit['kph'] = 'km/hr'

# Viscosity
Unit['P'] = 1/10, 'Pa.s'
# Kinetic Viscosity
Unit['St'] = 'cm2/s'

# Energy
Unit['cal'] = 4.184.rationalize, 'J'

# Ratio
Unit['%'] = 1/1e2, '1'
Unit['‰'] = 1/1e3, '1'
Unit['ppm'] = 1/1e6, '1'
Unit['ppb'] = 1/1e9, '1'


# Infomation
Unit << Unit.new do |conf|
  conf.symbol = 'bit'
#  conf.dimension = # 情報量の次元って何？
end
Unit['B'] = 8, 'bit'
Unit['bps'] = 'bit/s'
Unit['Bps'] = 'B/s'

