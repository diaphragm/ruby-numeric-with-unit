
class Unit
  class Config
    attr_reader :symbol, :dimension, :derivation
#    attr_reader :from_si, :to_si
    attr_reader :si, :proportional
    
    def initialize(parent=nil)
      @symbol = nil
      @dimension = Hash.new(0)
      @from_si = nil
      @to_si = nil
      @derivation = Hash.new(0)
      @si = false
      @proportional = nil
      
      @parent = parent
    end
    
    def compile
      @dimension.delete_if{|k,v| v.zero?}
      @derivation.delete_if{|k,v| v.zero?}
      @derivation.delete_if{|k,v| k.symbol.nil?}
      
      if @derivation.empty?
        @from_si ||= ->(x){x}
        @to_si ||= ->(x){x}
        @derivation[@parent] += 1 unless @parent.nil?
      else
        h = @derivation.sort_by{|u,v| u.symbol}.sort_by{|u,v| v} # ←どうしよう
        
        s1 = h.select{|u,v| v > 0}.map{|u,v| u.symbol + ((v.abs>1) ? v.abs.to_s : '')}.join('.')
        s2 = h.select{|u,v| v < 0}.map{|u,v| u.symbol + ((v.abs>1) ? v.abs.to_s : '')}.join('.')
        @symbol = s1 + (s2.empty? ? '' : "/(#{s2})")
        
        @derivation.each do |u,v|
          u.dimension.each do |d,i|
            @dimension[d] += i*v
          end
        end
        
        @from_si = @derivation.map{|u,v|
          prc = if v > 0
            ->(x){u.from_si(x)}
          else
            ->(x){x/(u.from_si(1)-u.from_si(0))}
          end
          [prc, v.abs]
        }.map{|prc,v|
          ->(x){
            v.times{x = prc[x]}
            x
          }
        }.reduce{|memo, prc|
          ->(x){memo[prc[x]]}
        }
        
        @to_si = @derivation.map{|u,v|
          prc = if v > 0
            ->(x){u.to_si(x)}
          else
            ->(x){x/(u.to_si(1)-u.to_si(0))}
          end
          [prc, v.abs]
        }.map{|prc,v|
          ->(x){
            v.times{x = prc[x]}
            x
          }
        }.reduce{|memo, prc|
          ->(x){memo[prc[x]]}
        }
      end
      
      @proportional = (@from_si[0].zero? and @to_si[0].zero?) ? true : false
      
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
    
    def derivation=(arg)
      raise unless arg.is_a?(Hash)
      @derivation = arg
    end
  end
end



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
  
  def self.[](arg)
    self.parse(arg.to_s)
  end
  
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
  
  def self.list
    @@list.map(&:symbol)
  end
  
  def self.<<(arg)
    if arg.is_a?(self)
      @@list << arg
    else
      @@list << Unit[arg]
    end
  end
  
  def self.delete(unit_symbol)
    @@list.delete_if{|unit| unit.symbol == unit_symbol}
  end
  
  def self.assign
    @@list << self.new{|config| yield(config)}
  end
  
  def self.parse(unit_str)
    a = parse_1st(unit_str)
    a.is_a?(Array) ? parse_2nd(a) : a
  end
  
  # 文字列を配列にパース
  # ex. 'J/(kg.K)' -> [#<Unit:J>, ['/', #<Unit:kg>, '.', #<Unit:K>]]
  def self.parse_1st(unit_str) # とても手続き的な書き方で禿げる
    u = @@list.select{|u| u.symbol == unit_str}.last
    return u if u
    
    return unit_str if unit_str =~ /^[\.\/]$/
    
    # 再帰で呼び出す用
    rec = ->(arg){__send__(__method__, arg)}
    
    a = unit_str.scan(/(?<=\().*(?=\))|[\.\/]|[^\(\)\.\/]+/)
    return a.map{|elem| rec[elem]} if a.size > 1
    
    m = unit_str.match(/-?\d+$/)
    return m.to_s if m and m.pre_match.empty?
    return [rec[m.pre_match], m.to_s] if m
    
    m = unit_str.match(/^(?<prefix>#{@@prefix.keys.join('|')})(?<unit>#{list.join('|')})$/)
    return rec[m[:unit]].cast(unit_str, @@prefix[m[:prefix]]) if m
    
    raise NoUnitError, "\"#{unit_str}\" is not assigned"
  end
  
  # 配列を組立単位に変換
  # derivationにそのまま突っ込んだほうがすっきりする気がする
  def self.parse_2nd(unit_array)
    # 再帰で呼び出す用
    rec = ->(arg){__send__(__method__, arg)}
    
    buff_ary = []
    buff_unit = ''
    buff_sign = 1
    
    unit_array.each do |elem|
      case elem
      when self
        buff_ary << elem ** buff_sign
      when '.'
        buff_sign = 1
      when '/'
        buff_sign = -1
      when Array
        buff_ary << rec[elem] ** buff_sign
      when /^-?\d+$/
        buff_ary[-1] **= elem.to_i
      end
    end
    
    buff_ary.reduce(:*)
  end
  
end



class Unit
  
  # Instance Methods
  
  attr_accessor :symbol
  attr_reader :dimension, :derivation
  
  def initialize
    
    # Unit::Configとinitializeの役割が分離できていないので見なおせ
    config = Config.new(self)
    yield(config) if block_given?
    config.compile
    
    @symbol = config.symbol
    @dimension = config.dimension
    @from_si = config.from_si
    @to_si = config.to_si
    
#    config.derivation[self] += 1 if config.derivation.empty?
    
    @derivation = config.derivation
  end
  
  def cast(new_symbol, factor = 1)
    self.class.new do |conf|
      conf.symbol = new_symbol
      conf.dimension = @dimension
      conf.from_si = ->(x){from_si(x) / factor}
      conf.to_si = ->(x){factor * to_si(x)}
    end
  end
  
  def to_s
    @symbol
  end
  
  def to_si(value)
    @to_si[value]
  end
  
  def from_si(value)
    @from_si[value]
  end
  
  
  def dimensionless?
    @dimension.all?{|k,v| v.zero?}
  end
  
  def dimension_equal?(other_unit)
    (@dimension.keys && other_unit.dimension.keys).all?{|k|
      @dimension[k] == other_unit.dimension[k]
    }
  end
  
  
  def *(other_unit)
    self.class.new do |conf|
      @derivation.each{|k, v| conf.derivation[k] += v}
      other_unit.derivation.each{|k, v| conf.derivation[k] += v}
    end
  end
  
  def /(other_unit)
    self.class.new do |conf|
      @derivation.each{|k, v| conf.derivation[k] += v}
      other_unit.derivation.each{|k, v| conf.derivation[k] -= v}
    end
  end
  
  def **(num)
    if num.zero?
      self.class.new
    elsif num < 0
      (self.class.new) / (self**(num.abs))
    else
      nu = Array.new(num.abs, self).reduce(:*)
    end
  end
  
end

class Unit
  class NoUnitError < StandardError; end
end

