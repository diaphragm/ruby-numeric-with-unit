# coding: utf-8

# 
# 独断と偏見による一般的な単位
# 

require 'numeric_with_unit/unit_definition/base'

class NumericWithUnit
  # Dimensionless
  Unit['-'] = ''
  Unit['1'] = ''

  # Time
  Unit['day'] = 24, 'hr'
  Unit['week'] = 7, 'day'
  Unit['month'] = 30, 'day' # 30日固定
  Unit['year'] = 12, 'month' # 360日固定

  # Mass
  Unit['ton'] = 1000, 'kg'
  Unit['oz'] = "28.349523125".to_r, 'g'
  Unit['lb'] = 16, 'oz'
  
  # Electriccal Resistance
  Unit['ohm'] = 'Ω'

  # Temperature
  Unit['degC'] = '℃'
  Unit['degR'] = "5/9".to_r, 'K'
  Unit << Unit.new do |conf|
    degr = Unit['degR']
    intercept = "459.67".to_r
    
    conf.symbol = 'degF'
    conf.dimension = degr.dimension
    conf.from_si{|x| degr.from_si(x)-intercept}
    conf.to_si{|x| degr.to_si(x+intercept)}
  end

  # Length
  Unit['Å'] = 10**-10, 'm'
  Unit['yd'] =  "0.9144".to_r, 'm'
  Unit['ft'] = "1/3".to_r, 'yd'
  Unit['in'] = "1/12".to_r, 'ft'
  Unit['mi'] = 5280, 'ft'
  Unit['100m'] = 100, 'm' # [kPa/100m]とか

  # Volume
  Unit['cc'] = 'cm3'
  Unit['bbl'] = "0.158987294928".to_r, 'm3'

  # Force
  Unit['kgf'] = "9.80665".to_r, 'N'
  Unit['lbf'] = "4.4482216152605".to_r, 'N'

  # Power
  Unit['PS'] = 75, 'kgf.m/s' # 仏馬力。小文字[ps]だとpico secondと区別がつかないため大文字で定義
  Unit['HP'] = 550, 'lbf.ft/s' # 英馬力

  # Pressure
  Unit['bar'] = 1e5, 'Pa'
  Unit['atm'] = 101325, 'Pa'
  Unit['Torr'] = "101325/760".to_r, 'Pa'
  Unit['mmHg'] = "101325/760".to_r, 'Pa'
  Unit['mHg'] = "1/1000".to_r, 'mmHg' # for compatible
  Unit['mH2O'] = "9806.65".to_r, 'Pa'
  Unit['mAq'] = 'mH2O'
  Unit['psi'] = "6894.76".to_r, 'Pa'

  # Guage圧の扱いどうしようか？
  Unit << Unit.new do |conf|
    pa = Unit['Pa']
    atm = 101325

    conf.symbol = 'PaG'
    conf.dimension = pa.dimension
    conf.from_si{|x| pa.from_si(x)-atm}
    conf.to_si{|x| pa.to_si(x+atm)}
  end

  # Speed
  Unit['kph'] = 'km/hr'

  # Flowrate
  Unit['lpm'] = 'L/min'

  # Viscosity
  Unit['P'] = "1/10".to_r, 'Pa.s'

  # Kinetic Viscosity
  Unit['St'] = 'cm2/s'

  # Energy
  Unit['cal'] = "4.184".to_r, 'J' # 熱力学カロリー
  Unit['MMkcal'] = 10**6 * 10**3, 'cal'
  Unit['Btu'] = "1055.05585262".to_r, 'J' # 国際蒸気表(IT)Btu
  Unit['MMBtu'] = 10**6, 'Btu'

  # Ratio
  Unit['%'] = 10**-2, ''
  Unit['‰'] = 10**-3, ''
  Unit['ppm'] = 10**-6, ''
  Unit['ppb'] = 10**-9, ''


  # Infomation
  Unit << Unit.new do |conf|
    conf.symbol = 'bit'
  #  conf.dimension[:] = # 情報量の次元って何？
  end
  Unit['B'] = 8, 'bit'
  Unit['bps'] = 'bit/s'
  Unit['Bps'] = 'B/s'
end
