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
    "#{@value.inspect} [#{@unit.symbol}] #{unit.dimension.inspect}"
  end

  # Return String with value and unit symbol
  def to_s
    "#{@value.to_s} #{@unit.symbol}"
  end

  # If ohter is NumericWithUnit and same dimension, comparing value with converting to si.
  # Else return nil.
  def <=>(other)
    if other.is_a?(self.class) and @unit.dimension_equal? other.unit
      @unit.to_si(@value) <=> other.unit.to_si(other.value)
    end
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

  # Convert to given unit
  def convert(unit)
    new_unit = unit.is_a?(Unit) ? unit : Unit[unit]

    unless @unit.dimension_equal? new_unit
      raise DimensionError, "Dimensions are different between #{@unit.symbol}#{@unit.dimension} #{new_unit.symbol}#{new_unit.dimension}"
    end

    new_value = new_unit.from_si(@unit.to_si(@value))
    self.class.new(new_value, new_unit)
  end
  alias :to_nwu :convert
  alias :[] :convert

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
    @unit.derivation.each do |k,v|
      res = v * num
      unless res.to_i == res # TODO: 整数かどうかの判定方法いいのこれで
        raise DimensionError, "Dimension of #{k.symbol}(#{v}*#{num}) must be Integer"
      end
    end

    self.class.new(@value**num, @unit**num)
  end

  def root(num)
    self**(Rational(1,num))
  end
  def sqrt; root(2) end # 平方根
  def cbrt; root(3) end # 立方根

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
    # TODO: 適当なのでもう少しいい感じに。いい感じに
    m = self.match(/.*?(?=[\s\(\[])/)
    value = m.to_s
    unit = m.post_match.strip.gsub(/^\[|\]$/, '')
    NumericWithUnit.new(value.__send__(mthd), unit)
  end
end



# unit definition
require 'numeric_with_unit/unit_definition/base'
require 'numeric_with_unit/unit_definition/common'
