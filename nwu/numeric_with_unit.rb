
require 'nwu/unit'

class NumericWithUnit
  include Comparable
  
  def self.[](value, unit)
    new(value, unit)
  end
  
  attr_reader :value, :unit
  
  def initialize(value, unit)
    @value = value
    @unit = (Unit === unit) ? unit : Unit[unit]
  end
  
  def <=>(other)
    if @unit.dimension_equal? other.unit
      @unit.to_si(@value) <=> other.unit.to_si(other.value)
    end
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
  
  def to_u(unit)
    new_unit = Unit[unit]
    
    unless @unit.dimension_equal? new_unit
      raise "Dimension Error: between\n\t#{@unit.dimension}\n\t#{new_unit.dimension}"
    end
    
    new_value = new_unit.from_si(@unit.to_si(@value))
    self.class.new(new_value, new_unit)
  end
  
  def [](unit)
    to_u(unit)
  end
  
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
        raise "Dimension Error: between\n\t#{@unit.dimension}\n\t#{other.unit.dimension}"
      end
    else
      warn "Calculating Numeric with Unit and Numeric without Unit"
      self.class.new(@value + other, @unit)
    end
  end
  
  def -(other)
    +(-other)
  end
  
  def *(other)
    if self.class == other.class
      self.class.new(@value * other.value, @unit * other.unit)
    else
      self.class.new(@value * other, @unit)
    end
  end
  
  def /(other)
    if self.class == other.class
      self.class.new(@value / other.value, @unit / other.unit)
    else
      self.class.new(@value / other, @unit)
    end
  end
  
end

