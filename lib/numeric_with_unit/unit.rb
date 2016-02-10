# coding: utf-8

class NumericWithUnit
  class Unit
    class Config
      attr_reader :symbol, :dimension
      attr_reader :si
      
      def initialize()
        @symbol = nil
        @dimension = Hash.new(0)
        @from_si = nil
        @to_si = nil
        @si = false
      end
      
      def compile
        @dimension.delete_if{|k,v| v.zero?}
        
        @from_si ||= ->(x){x}
        @to_si ||= ->(x){x}

        self
      end
      
      def symbol=(arg)
        @symbol = arg.to_s
      end
      
      def dimension=(arg)
        raise unless arg.is_a?(Hash)
        @dimension = arg
      end
      
      def from_si=(arg)
        raise unless arg.is_a?(Proc)
        @from_si = arg
      end
      
      def from_si(&block)
        if block_given?
          @from_si = block
        else
          @from_si
        end
      end
      
      def to_si=(arg)
        raise unless arg.is_a?(Proc)
        @to_si = arg
      end
      
      def to_si(&block)
        if block_given?
          @to_si = block
        else
          @to_si
        end
      end
      
      def si=(arg)
        raise unless [TrueClass, FalseClass].any?{|klass|arg.is_a?(klass)}
        @si = arg
      end
    end
  end
end



class NumericWithUnit
  class Unit
    @@list = []
    @@prefix = {
      'Y' => 10**24, 
      'Z' => 10**21, 
      'E' => 10**18, 
      'P' => 10**15, 
      'T' => 10**12, 
      'G' => 10**9, 
      'M' => 10**6, 
      'k' => 10**3, 
      'h' => 10**2, 
      'da' => 10**1, 
      'd' => 10**-1, 
      'c' => 10**-2, 
      'm' => 10**-3, 
      'μ' => 10**-6, 
      'u' => 10**-6, 
      'n' => 10**-9, 
      'p' => 10**-12, 
      'f' => 10**-15, 
      'a' => 10**-18, 
      'z' => 10**-21, 
      'y' => 10**-24,
      'Ki' => 2**10,
      'Mi' => 2**20,
      'Gi' => 2**30,
      'Ti' => 2**40,
      'Pi' => 2**50,
      'Ei' => 2**60,
      'Zi' => 2**70,
      'Yi' => 2**80
    }
    
    # class methods

    # create new unit from derivation _(for internal use)_ .
    def self.derive #(block)
      derivation = Hash.new(0)
      yield(derivation)
      return Unit.new if derivation.empty?
      
      derivation.delete_if{|k,v| k.symbol.nil?}
      
      # constructing symbol
      h = derivation.reject{|k,v| k.symbol.empty?}.sort_by{|u,v| u.symbol}.sort_by{|u,v| v}
      syms_pos = h.select{|u,v| v > 0}.map{|u,v| u.symbol + (v.abs>1 ? v.abs.to_s : '')}
      syms_neg = h.select{|u,v| v < 0}.map{|u,v| u.symbol + (v.abs>1 ? v.abs.to_s : '')}
      symbol = syms_pos.join('.')
      symbol += '/' + (syms_neg.size>1 ? "(#{syms_neg.join('.')})" : "#{syms_neg.first}") unless syms_neg.empty?
      
      # constructing dimension
      dimension = Hash.new(0)
      derivation.each do |u,v|
        u.dimension.each do |d,i|
          dimension[d] += i*v
        end
      end
      
      # constructing from_si proc
      from_si = derivation.map{|u,v|
        prc = if v > 0
          ->(x){u.from_si(x)}
        else
          ->(x){x.quo(u.from_si(1)-u.from_si(0))} #FIXME: ℃とKの変換のような場合に、変換式の切片を消すため。変換式が線形じゃないケースは想定していない
        end
        [prc, v.abs]
      }.map{|prc,v|
        ->(x){ v.times{x = prc[x]}; x }
      }.reduce{|memo, prc|
        ->(x){memo[prc[x]]}
      }
      
      # constructing to_si proc
      to_si = derivation.map{|u,v|
        prc = if v > 0
          ->(x){u.to_si(x)}
        else
          ->(x){x.quo(u.to_si(1)-u.to_si(0))} #FIXME: ℃とKの変換のような場合に、変換式の切片を消すため。変換式が線形じゃないケースは想定していない
        end
        [prc, v.abs]
      }.map{|prc,v|
        ->(x){ v.times{x = prc[x]}; x }
      }.reduce{|memo, prc|
        ->(x){memo[prc[x]]}
      }
      
      # deriving new unit
      self.new(derivation){|config|
        config.symbol = symbol
        config.dimension = dimension
        config.from_si = from_si
        config.to_si = to_si
      }
    end
    
    # apply to_s to arg and return parsed unit.
    def self.[](arg)
      self.parse(arg.to_s)
    end
    
    # cast unit and add unit to base unit list at the same time.
    def self.[]=(key, arg)
      if arg.is_a?(Array) and arg.size == 2
        a = [key, arg.first]
        u = arg.last
      else
        a = [key]
        u = arg
      end
      @@list << (u.is_a?(self) ? u : self[u]).cast(*a)
    end
    
    # return base unit list.
    def self.list
      @@list
    end
    
    # add unit to base unit list.
    def self.<<(arg)
      if arg.is_a?(self)
        @@list << arg
      else
        @@list << Unit[arg]
      end
    end
    
    # remove unit from base unit list.
    def self.delete(unit_symbol)
      @@list.delete_if{|unit| unit.symbol == unit_symbol}
    end
    
    # create new unit and add unit to base unit list at the same time.
    def self.assign
      @@list << self.new{|config| yield(config)}
    end


    # parsing unit_str (ex. "kg", km/hr", "cm2") to (derived) unit.
    def self.parse(unit_str)
      rec = ->(arg){__send__(__method__, arg)}

      dervation_str = parse_3rd(parse_2nd(parse_1st(unit_str)))
      derive{|derivation|
        dervation_str.each do |unit_str, order|
          if i = @@list.rindex{|unit| unit.symbol == unit_str}
            derivation[@@list[i]] += order
          elsif m = unit_str.match(/^(?<prefix>#{@@prefix.keys.join('|')})(?<unit>#{list.join('|')})$/) and m[:unit].empty?.!
            u = rec[m[:unit]].cast(unit_str, @@prefix[m[:prefix]])
            derivation[u] += order
          else
            raise NoUnitError, "[#{unit_str}] is not defined!"
          end
        end
      }
    end

    def self.parse_1st(unit_str) #:nodoc:
      return [unit_str] if @@list.rindex{|u| u.symbol == unit_str}

      rec = ->(arg){__send__(__method__, arg)}
      
      a = []
      tmp = ''
      nest = 0
      unit_str.each_char do |char|
        nest -= 1 if char == ')'
        
        if nest == 0
          case char
          when '(', ')'
            a << rec[tmp] unless tmp.empty?
            tmp = ''
          when '.', '/'
            a << tmp unless tmp.empty?
            a << char
            tmp = ''
          else
            tmp += char
          end
        else
          tmp += char
        end
        
        nest += 1 if char == '('
        raise StandardError, "parse error" if nest < 0
      end
      a << tmp unless tmp.empty?
      a
    end


    def self.parse_2nd(unit_array) #:nodoc:
      rec = ->(arg){__send__(__method__, arg)}

      a = []
      sign = 1
      order = 1
      tmp = nil
      unit_array.each do |unit_x|
        if tmp and not( unit_x.is_a?(String) and unit_x =~ /^\d+$/ )
          a << {unit: tmp, order: sign*order} if tmp
          sign = 1
          order = 1
          tmp = nil
        end

        case unit_x
        when '.'
          sign = 1
        when '/'
          sign = -1
        when /^(-?\d+)$/
          order = $1.to_i
        when /^(.+?)(-?\d+)$/
          order = $2.to_i
          tmp = $1
        else
          tmp = unit_x.is_a?(Array) ? rec[unit_x] : unit_x
        end
      end
      a << {unit: tmp, order: sign*order} if tmp
      a
    end

    def self.parse_3rd(unit_x, derivation=Hash.new(0), order=1) #:nodoc:
      rec = ->(*arg){__send__(__method__, *arg)}

      if unit_x.is_a?(Hash)
        if unit_x[:unit].is_a?(Array)
          rec[unit_x[:unit], derivation, order * unit_x[:order]]
        else
          derivation[unit_x[:unit]] += (order * unit_x[:order])
        end
      elsif unit_x.is_a?(Array)
        unit_x.each do |x|
          rec[x, derivation, order]
        end
      else
        raise StandardError, %(maybe bug in "numeric_with_unit" gem)
      end
      derivation
    end

    private_class_method :parse_1st, :parse_2nd, :parse_3rd

  end



  class Unit
    
    # Instance Methods
    
    attr_reader :symbol
    attr_reader :dimension, :derivation
    
    def initialize(derivation=nil)
      # TODO: Unit::Configとinitializeの役割が分離できていないので見なおせ
      config = Config.new
      yield(config) if block_given?
      config.compile
      
      @symbol = config.symbol
      @dimension = config.dimension
      @from_si = config.from_si
      @to_si = config.to_si
      
      unless derivation
        derivation = Hash.new(0)
        derivation[self] += 1
      end
      @derivation = derivation
    end
    
    # create new unit with new symbol and factor from self.
    # use for converting [in] = 25.4[mm] .
    def cast(new_symbol, factor = 1)
      self.class.new do |config|
        config.symbol = new_symbol
        config.dimension = @dimension
        config.from_si = ->(x){from_si(x.quo(factor))}
        config.to_si = ->(x){to_si(x * factor)}
      end
    end
    
    def to_s
      @symbol
    end
    
    def inspect
      "#<#{self.class}:[#{@symbol}] #{@dimension}>"
    end
    
    def to_si(value)
      @to_si.call(value)
    end
    
    def from_si(value)
      @from_si.call(value)
    end
    
    
    def dimensionless?
      @dimension.all?{|k,v| v.zero?}
    end
    
    # return true if self and other_unit have the same dimension.
    def dimension_equal?(other_unit)
      (@dimension.keys | other_unit.dimension.keys).all?{|k|
        @dimension[k] == other_unit.dimension[k]
      }
    end
    
    def ==(other)
      if other.is_a?(self.class)
        symbol == other.symbol and dimension == other.dimension
      else
        super
      end
    end
    
    def *(other_unit)
      self.class.derive do |derivation|
        @derivation.each{|k, v| derivation[k] += v}
        other_unit.derivation.each{|k, v| derivation[k] += v}
      end
    end
    
    def /(other_unit)
      self.class.derive do |derivation|
        @derivation.each{|k, v| derivation[k] += v}
        other_unit.derivation.each{|k, v| derivation[k] -= v}
      end
    end
    
    def **(num)
      if num.zero?
        self.class.new
      else
        self.class.derive do |derivation|
          # NOTE:
          # ここto_iでOKか？v*numが整数じゃなければraiseすべき？→すべき→NumericWithUnitでやるべき？
          # Unitでは整数じゃない次数の単位は許容すべきか否か→していい気がする
          @derivation.each{|k, v| derivation[k] = (v*num).to_i}
        end
      end
    end
    
    
    def simplify
      self.class.derive{|derivation|
        @dimension.each do|d,o|
          u = self.class.list.find{|u| u.dimension == {d => 1}} #TODO: find? ok?
          raise NoUnitError, "No unit with #{{d=>1}} dimension is assined." unless u
          derivation[u] = o
        end
      }
    end
    
  end

  class Unit
    class NoUnitError < StandardError; end
  end
end
