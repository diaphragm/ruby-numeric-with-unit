# coding: utf-8

#
# SI base units & SI derived units & Units in use with SI
# 

require 'mathn'
require 'nwu/unit'

# Dimensionless
Unit << Unit.new do |conf|
  conf.symbol = ''
end

#
# SI base units
#

# Length
Unit << Unit.new do |conf|
  conf.symbol = 'm'
  conf.dimension[:L] = 1
  conf.si = true
end

# Mass
Unit << Unit.new do |conf|
  conf.symbol = 'kg'
  conf.dimension[:M] = 1
  conf.si = true
end
Unit['g'] = 1/1000, 'kg' # for compatible

# Time
Unit << Unit.new do |conf|
  conf.symbol = 's'
  conf.dimension[:T] = 1
  conf.si = true
end

# Electric Current
Unit << Unit.new do |conf|
  conf.symbol = 'A'
  conf.dimension[:I] = 1
  conf.si = true
end

# Thermodynamic Temperature
Unit << Unit.new do |conf|
  conf.symbol = 'K'
  conf.dimension[:Θ] = 1
  conf.si = true
end

# Amout of Substance
Unit << Unit.new do |conf|
  conf.symbol = 'mol'
  conf.dimension[:N] = 1
  conf.si = true
end

# Luminous Intensity
Unit << Unit.new do |conf|
  conf.symbol = 'cd'
  conf.dimension[:J] = 1
  conf.si = true
end



# 
# SI derived units
# 

# Frequency
Unit['Hz'] = '/s'

# Angle
Unit['rad'] = 'm/m'
Unit['°'] = Math::PI/180, 'rad'
Unit['′'] = 1/60, '°'
Unit['″'] = 1/60, '′'

# Solid Angle
Unit['sr'] = 'm2/m2'

# Force
Unit['N'] = 'kg.m/s2'

# Pressure
Unit['Pa'] = 'N/m2'

# Energy
Unit['J'] = 'N.m'

# Power
Unit['W'] = 'J/s'

# Electric Charge
Unit['C'] = 's.A'

# Voltage
Unit['V'] = 'W/A'

# Electriccal Capacitance
Unit['F'] = 'C/V'

# Electriccal Resistance
Unit['Ω'] = 'V/A'
Unit['ohm'] = 'Ω'

# Electriccal Conductance
Unit['S'] = 'A/V'

# Magnetic Flux
Unit['Wb'] = 'J/A'

# Magnetic Field Strength
Unit['T'] = 'Wb/m2'

# Inductance
Unit['H'] = 'V.s/A'

# Temperature
Unit << Unit.new do |conf|
  k = Unit['K']
  intercept = 273.15.rationalize
  
  conf.symbol = '℃'
  conf.dimension = k.dimension
  conf.from_si{|x| k.from_si(x)-intercept}
  conf.to_si{|x| k.to_si(x+intercept)}
end
Unit['degC'] = '℃'

# Luminouse flux
Unit['lx'] = 'cd.sr'

# Radioactivity
Unit['Bq'] = '/s'

# Absorbed Dose
Unit['Gy'] = 'J/kg'

# Equivalent Dose
Unit['Sv'] = 'J/kg'

# Catalytic Activity
Unit['kat'] = 'mol/s'



#
# Units in use with SI
#

# Time
Unit['min'] = 60, 's'
Unit['hr'] = 60, 'min'

# Area
Unit['ha'] = 10000, 'm2'
Unit['a'] = 1/100, 'ha'  # for compatible

# Volume
Unit['L'] = 'dm3'

# Mass
Unit['t'] = 1000, 'kg'

# Energy
Unit['eV'] = 1.6021765314e-19.rationalize, 'J'

# Mass
Unit['u'] = 1.6605388628e-27.rationalize, 'kg'
Unit['Da'] = 'u'

# Length
Unit['ua'] = 1.495978706916e11.rationalize, 'm'

