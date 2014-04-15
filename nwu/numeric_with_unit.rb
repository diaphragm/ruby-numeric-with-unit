
require 'nwu/unit'

class NumericWithUnit
  include Comparable
  
  def self.[](value, unit)
    new(value, unit)
  end
  
  attr_reader :value, :unit
  
  def initialize(value, unit)
    @value = value
    @unit = unit.is_a?(Unit) ? unit : Unit[unit]
  end
  
  def <=>(other)
    if @unit.dimension_equal? other.unit
      @unit.to_si(@value) <=> other.unit.to_si(other.value)
    end
  end
  
  def succ
    self.class.new(@value.succ, @unit)
  end
  
  def inspect
    "#{@value.inspect} [#{@unit.symbol}] #{@unit.dimension}"
  end
  
  def to_s
    "#{@value} #{@unit}"
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
      raise DimensionError, "Dimensions are different between #{@unit.dimension} #{new_unit.dimension}"
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
    if self.class == other.class
      if @unit.dimension_equal? other.unit
        v1 = @unit.to_si(@value)
        v2 = other.unit.to_si(other.value)
        vr = @unit.from_si(v1+v2)
        self.class.new(vr, @unit)
      else
        raise DimensionError, "Dimensions are different between #{@unit.dimension} #{other.unit.dimension}"
      end
    else
      warn "Warning: Calculating Numeric-with-Unit and Numeric`-without-Unit'"
      self.class.new(@value + other, @unit)
    end
  end
  
  def -(other)
    self + (-other)
  end
  
  def *(other)
    # other * self の場合に対応してないの何とかしたい
    ou = if not @unit.derivation.select{|k,v| k == other.unit}.empty?
      other
    elsif @unit.dimension_equal? other.unit
      other[@unit]
    elsif not (h = @unit.derivation.select{|k,v| k.dimension_equal? other.unit}).empty?
      other[ h.sort_by{|k,v| v}.first.first ]
    else
      other
    end
    
    self.class.new(@value * ou.value, @unit * ou.unit)
  end
  
  def /(other)
    ou = if not @unit.derivation.select{|k,v| k == other.unit}.empty?
      other
    elsif @unit.dimension_equal? other.unit
      other[@unit]
    elsif not (h = @unit.derivation.select{|k,v| k.dimension_equal? other.unit}).empty?
      other[ h.sort_by{|k,v| v}.first.first ]
    else
      other
    end
    
    self.class.new(@value / ou.value, @unit / ou.unit)
  end
  
  def **(num)
    self.class.new(@value**num, @unit**num)
  end
  
  def coerce(other)
    if self.class == other.class
      [other, self]
    else
      [self.class.new(other, Unit.new), self]
    end
  end
end

#class Numeric
#  def *(other)
#    (other == Unit) ? other * self : super
#  end
#end

class NumericWithUnit
  class DimensionError < StandardError; end
end