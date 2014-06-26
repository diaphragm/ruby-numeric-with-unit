# coding: utf-8

require 'nwu/base_unit'

Unit['yd'] =  0.9144 , 'm'
Unit['ft'] = 1.0/3.0, 'yd'
Unit['th'] = 1.0/12000.0, 'ft'
Unit['in'] = 1.0/12.0, 'ft'
Unit['ch'] = 66, 'ft'
Unit['fur'] = 660, 'ft'
Unit['mi'] = 5280, 'ft'
Unit['lea'] = 15840, 'ft'


Unit['floz'] = 2.84130625e-05, 'm3'
Unit['gi'] = 5, 'floz'
Unit['pt'] = 20, 'floz'
Unit['qt'] = 40, 'floz'
Unit['gal'] = 160, 'floz'

Unit['bbl'] = 0.158987294928, 'm3'


Unit['oz'] = 0.45359237, 'kg'
Unit['gr'] = 1.0/7000.0, 'oz'
Unit['dr'] = 1.0/256.0, 'oz'
Unit['lb'] = 1.0/16.0, 'oz'
Unit['st'] = 14.0, 'oz'
Unit['qtr'] = 28.0, 'oz'
Unit['cwt'] = 112.0, 'oz'
Unit['t'] = 2240, 'oz'


Unit['degR'] = 9/5, 'K'

Unit << Unit.new do |conf|
  deg_r = Unit['degR']
  conf.symbol = '℉'
  conf.dimension = deg_r.dimension
  conf.from_si = ->(x){(deg_r.from_si(x)) - 459.67}
  conf.to_si = ->(x){deg_r.to_si(x + 459.67)}
end
Unit['degF'] = '℉'
