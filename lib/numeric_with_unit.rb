# coding: utf-8

require 'numeric_with_unit/unit'

class NumericWithUnit
  include Comparable

  attr_reader :value, :unit

  def initialize(value, unit)
    @value = value
    @unit = unit.is_a?(Unit) ? unit : Unit[unit]
  end

  # Return String for inspect
  def inspect
    "#{@value.inspect} [#{@unit.symbol}] #{@unit.dimension.inspect}"
  end

  # Return String with value and unit symbol
  def to_s
    "#{@value.to_s} #{@unit.symbol}"
  end

  # If ohter is NumericWithUnit and same dimension, comparing value with converting to si.
  # Else return nil.
  def <=>(other)
    if other.is_a?(self.class) and @unit.dimension_equal? other.unit
      value_si <=> other.value_si
    end
  end

  def ===(other)
    self.<=>(other) == 0
  end

  # Return succed value with same unit.
  def succ
    self.class.new(@value.succ, @unit)
  end

  # Return value.to_i
  def to_i
    @value.to_i
  end

  # Return value.to_f
  def to_f
    @value.to_f
  end

  # Return value in si
  def value_si
    @unit.to_si(@value)
  end

  # Convert to given unit
  def convert!(unit)
    new_unit = unit.is_a?(Unit) ? unit : Unit[unit]

    unless @unit.dimension_equal? new_unit
      raise DimensionError, "Dimensions are different between #{@unit.symbol}#{@unit.dimension} #{new_unit.symbol}#{new_unit.dimension}"
    end

    new_value = new_unit.from_si(@unit.to_si(@value))
    @value, @unit = new_value, new_unit
    self
  end
  alias :[] :convert!
  
  def convert(unit)
    clone.convert!(unit)
  end
  alias :to_nwu :convert

  # Convert to simple unit
  def simplify
    convert(@unit.simplify)
  end


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
    add_with_other_unit(nwu)
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
    if other.is_a?(self.class)
      [other, self]
    else
      [self.class.new(other, Unit.new), self]
    end
  end

  def **(num)
    # Dimension Check
    if @unit.derivation.all?{|k,v| o = v * num; o.to_i == o} # TODO: 整数かどうかの判定方法いいのこれで
     self.class.new(@value**num, @unit**num)
    else
      nu = @unit.simplify
      if nu.derivation.all?{|k,v| o = v * num; o.to_i == o}
        nv = nu.from_si(@unit.to_si(@value))
        self.class.new(nv ** num, nu**num)
      else
        raise DimensionError, "All derivating units order multiplied #{num} must be integer"
      end
   end
  end

  def root(num)
    self**(Rational(1,num))
  end
  def sqrt; root(2) end # 平方根
  def cbrt; root(3) end # 立方根

  def ceil
    self.class.new(@value.ceil, @unit)
  end

  def floor
    self.class.new(@value.floor, @unit)
  end

  def round
    self.class.new(@value.round, @unit)
  end

  def truncate
    self.class.new(@value.truncate, @unit)
  end


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
    onwu = adjust_other_unit(other)
    self.class.new(@value * onwu.value, @unit * onwu.unit)
  end

  def devide_with_other_unit(other)
    onwu = adjust_other_unit(other)
    self.class.new(@value / onwu.value, @unit / onwu.unit)
  end

  # なるべくselfと同じ単位を使用するようにotherを変換します。
  def adjust_other_unit(other)
    if @unit.derivation.any?{|k,v| k == other.unit} # [L/min]*[min]などのケース
      other
    elsif h = @unit.derivation.find{|k,v| k.dimension_equal? other.unit} # [L/min]*[s]などのケース
      other[ h.first ]
    elsif @unit.dimension_equal? other.unit # [mm]*[cm]などのケース
      other[@unit]
    else
      other
    end
  end

end



class NumericWithUnit
  class DimensionError < StandardError; end
end



require 'numeric_with_unit/core_ext'

# unit definition
require 'numeric_with_unit/unit_definition/base'
require 'numeric_with_unit/unit_definition/common'
