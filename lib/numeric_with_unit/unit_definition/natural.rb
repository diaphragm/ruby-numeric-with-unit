# coding: utf-8

require 'numeric_with_unit/unit_definition/base'

# Naural Units
# Speed
Unit['c0'] = "299792458.0".to_r, 'm/s'
# Action
Unit['ħ'] = "1.0545716818e−34".to_r, 'J.s'
Unit['h'] = 'ħ'  # alias
# Mass
Unit['me'] = "9.109382616e−31".to_r, 'kg'
# Time
Unit['ħ/(me.(c0)2)'] = "1.288088667786e-21".to_r, 's'  # なんかきもい
