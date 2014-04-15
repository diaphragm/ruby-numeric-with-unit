
# 
# 独断と偏見による
# 

require 'nwu/base_unit'

Unit['-'] = '1'

# Time
Unit['day'] = 24, 'hr'
Unit['week'] = 7, 'day'
Unit['month'] = 30, 'day' # 30日固定
Unit['year'] = 12, 'month' # 360日固定

# Mass
Unit['ton'] = 1000, 'kg'
Unit['oz'] = 0.45359237, 'kg'
Unit['lb'] = 1.0/16.0, 'oz'

# Length
Unit['Å'] = 1e-10, 'm'
Unit['yd'] =  0.9144 , 'm'
Unit['ft'] = 1.0/3.0, 'yd'
Unit['mi'] = 5280.0, 'ft'

# Volume
Unit['cc'] = 'cm3'
Unit['bbl'] = 0.158987294928, 'm3'

# Force
Unit['kgf'] = 9.80665, 'N'

# Pressure
Unit['bar'] = 1e5, 'Pa'
Unit['atm'] = 101325.0, 'Pa'
Unit['Torr'] = 101325.0/760.0, 'Pa'
Unit['mmHg'] = 101325.0/760.0, 'Pa'
Unit['mHg'] = 1e-3, 'mmHg' # for compatible
Unit['mH2O'] = 9806.65, 'Pa'
Unit['mAq'] = 'mH2O'

# Speed
Unit['kph'] = 'km/hr'

# Viscosity
Unit['P'] = 0.1, 'Pa.s'
# Kinetic Viscosity
Unit['St'] = 'cm2/s'

# Energy
Unit['cal'] = 4.184, 'J'

# Ratio
Unit['%'] = 1e-2, '1'
Unit['‰'] = 1e-3, '1'
Unit['ppm'] = 1e-6, '1'
Unit['ppb'] = 1e-9, '1'


# Infomation
Unit << Unit.new do |conf|
  conf.symbol = 'bit'
#  conf.dimension = # 情報量の次元って何？
end
Unit['B'] = 8, 'bit'
Unit['bps'] = 'bit/s'
Unit['Bps'] = 'B/s'

