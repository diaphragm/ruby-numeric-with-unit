# coding: utf-8

Gem::Specification.new do |s|
  s.name = "numeric_with_unit"
  s.version = "0.3.1"

  s.summary = "Super cool gem that can calculate like this; (50['L/min'] + 3['m3/hr'] ) * 30['min'] #=> 3000 L"
  s.author = "diaphragm"
  s.description = "This gem provide NumerichWithUnit class to calculate numeric easily with unit of measurement."
  s.license = "MIT"
  s.homepage = "https://github.com/diaphragm/ruby-numeric-with-unit"

  s.required_ruby_version = '>=2.0.0'
  s.files = Dir['LICENSE', 'README.md', 'lib/**/*']
end
