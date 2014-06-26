# coding: utf-8

require 'nwu/unit'

class NumericWithUnit
  include Comparable
  
  attr_reader :value, :unit
  
  def initialize(value, unit)
    @value = value
    @unit = unit.is_a?(Unit) ? unit : Unit[unit]
  end
  
  def inspect
    "#{@value.inspect} [#{@unit.symbol}] #{unit.dimension.inspect}"
  end
  
  def to_s
    "#{@value.to_s} #{@unit.symbol}"
  end
  
  # otherがNumericWithUnitだったらsi単位に変換して比較、そうでなければvaluを比較
  def <=>(other)
    if other.is_a?(self.class)
      if @unit.dimension_equal? other.unit
        @unit.to_si(@value) <=> other.unit.to_si(other.value)
      end
    else
      self.value <=> other
    end
  end
  
  def succ
    self.class.new(@value.succ, @unit)
  end
  
  def to_i
    @value.to_i
  end
  
  def to_f
    @value.to_f
  end
  
  def to_nwu(unit)
    new_unit = unit.is_a?(Unit) ? unit : Unit[unit]
    
    unless @unit.dimension_equal? new_unit
      raise DimensionError, "Dimensions are different between #{@unit.symbol}#{@unit.dimension} #{new_unit.symbol}#{new_unit.dimension}"
    end
    
    new_value = new_unit.from_si(@unit.to_si(@value))
    self.class.new(new_value, new_unit)
  end
  alias :[] :to_nwu
  
  def +@
    self
  end
  
  def -@
    self.class.new(-@value, @unit)
  end
  
  def +(other)
    nwu = if other.is_a? self.class
      other
    else
      self.class.new(other, Unit.new)
    end
    add_with_otunit(nwu)
  end
  
  def -(other)
    self + (-other)
  end
  
  def *(other)
    case other
    when self.class
      multiply_with_other_unit(other)
    else
      self.class.new(@value*other, @unit)
    end
  end
  
  def /(other)
    case other
    when self.class
      devide_with_other_unit(other)
    else
      self.class.new(@value/other, @unit)
    end
  end
  
  def coerce(other)
    if other.is_a?(other.class)
      [other, self]
    else
      [self.class.new(other, Unit.new), self]
    end
  end
  
  def **(num)
    self.class.new(@value**num, @unit**num)
  end
  
  def root(num)
    self**(Rational(1,num))
  end
  def sqrt; root(2) end
  
  private
  
  def add_with_other_unit(other)
    if @unit.dimension_equal? other.unit
      v1 = @unit.to_si(@value)
      v2 = other.unit.to_si(other.value)
      vr = @unit.from_si(v1+v2)
      self.class.new(vr, @unit)
    else
      raise DimensionError, "Dimensions are different between #{@unit.dimension} #{other.unit.dimension}"
    end
  end
  
  def multiply_with_other_unit(other)
    onwu = if not @unit.derivation.select{|k,v| k == other.unit}.empty?
      other
    elsif @unit.dimension_equal? other.unit
      other[@unit]
    elsif not (h = @unit.derivation.select{|k,v| k.dimension_equal? other.unit}).empty?
      other[ h.sort_by{|k,v| v}.first.first ]
    else
      other
    end
    
    self.class.new(@value * onwu.value, @unit * onwu.unit)
  end
  
  def devide_with_other_unit(other)
    onwu = if not @unit.derivation.select{|k,v| k == other.unit}.empty?
      other
    elsif @unit.dimension_equal? other.unit
      other[@unit]
    elsif not (h = @unit.derivation.select{|k,v| k.dimension_equal? other.unit}).empty?
      other[ h.sort_by{|k,v| v}.first.first ]
    else
      other
    end
    
    self.class.new(@value / onwu.value, @unit / onwu.unit)
  end
  
end

class NumericWithUnit
  class DimensionError < StandardError; end
end



class Fixnum
  def to_nwu(unit)
    NumericWithUnit.new(self, unit)
  end
end

class Bignum
  def to_nwu(unit)
    NumericWithUnit.new(self, unit)
  end
end

class Numeric
  def to_nwu(unit)
    NumericWithUnit.new(self, unit)
  end
end

class String
  def to_nwu(mthd=:to_r)
    m = self.match /(?<value>.+) (?<unit>.+)/ # 適当
    NumericWithUnit[m[:value].__send__(mthd), m[:unit]]
  end
end

