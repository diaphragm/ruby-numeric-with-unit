# coding: utf-8

require 'nwu/base_unit'

Unit['yd'] =  "0.9144".to_r , 'm'
Unit['ft'] = "1/3".to_r, 'yd'
Unit['th'] = "1/12000".to_r, 'ft'
Unit['in'] = "1/12".to_r, 'ft'
Unit['ch'] = 66, 'ft'
Unit['fur'] = 660, 'ft'
Unit['mi'] = 5280, 'ft'
Unit['lea'] = 15840, 'ft'


Unit['floz'] = "2.84130625e-05".to_r, 'm3'
Unit['gi'] = 5, 'floz'
Unit['pt'] = 20, 'floz'
Unit['qt'] = 40, 'floz'
Unit['gal'] = 160, 'floz'

Unit['bbl'] = "0.158987294928".to_r, 'm3'


Unit['oz'] = "0.45359237".to_r, 'kg'
Unit['gr'] = "1/7000".to_r, 'oz'
Unit['dr'] = "1/256".to_r, 'oz'
Unit['lb'] = "1/16".to_r, 'oz'
Unit['st'] = 14, 'oz'
Unit['qtr'] = 28, 'oz'
Unit['cwt'] = 112, 'oz'
Unit['t'] = 2240, 'oz'


Unit['degR'] = "9/5".to_r, 'K'

Unit << Unit.new do |conf|
  deg_r = Unit['degR']
  conf.symbol = '℉'
  conf.dimension = deg_r.dimension
  conf.from_si = ->(x){(deg_r.from_si(x)) - 459.67}
  conf.to_si = ->(x){deg_r.to_si(x + 459.67)}
end
Unit['degF'] = '℉'
