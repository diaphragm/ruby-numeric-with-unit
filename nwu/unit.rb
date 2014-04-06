
require 'mathn'

class Unit
  class Config
    attr_reader :symbol, :dimension, :derivation
#    attr_reader :from_si, :to_si
    attr_reader :si
    
    def initialize
      @symbol = nil
      @dimension = Hash.new(0)
      @from_si = nil
      @to_si = nil
      @si = false
      @derivation = Hash.new(0)
    end
    
    def compile
      @derivation.delete_if{|k,v| k.symbol.nil?}
      if @derivation.empty?
        @from_si ||= ->(x){x}
        @to_si ||= ->(x){x}
        @derivation[self] += 1
      else
        h = @derivation.sort_by{|u,v| u.symbol}.sort_by{|u,v| v} # ←どうしよう
        
        s1 = h.select{|u,v| v > 0}.map{|u,v| u.symbol + ((v.abs>1) ? v.abs.to_s : '')}.join('.')
        s2 = h.select{|u,v| v < 0}.map{|u,v| u.symbol + ((v.abs>1) ? v.abs.to_s : '')}.join('.')
        @symbol = s1 + (s2.empty? ? '' : "/(#{s2})")
        
#        @from_si = @derivation.map{|u,v| ->(x){u.from_si[x]**(-v)}}.reduce{|f,g| ->(x){f[g[x]]}}
#        @to_si = @derivation.map{|u,v| ->(x){u.to_si[x]**v}}.reduce{|f,g| ->(x){f[g[x]]}}
      end
    end
    
    def symbol=(arg)
      @symbol = arg.to_s
    end
    
    def dimension=(arg)
      raise unless Hash === arg
      @dimension = arg
    end
    
    def from_si=(arg)
      raise unless Proc === arg
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
      raise unless Proc === arg
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
      raise unless [TrueClass, FalseClass].any?{|klass| klass === arg}
      @si = arg
    end
    
    def derivation=(arg)
      raise unless Hash === arg
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
    'y' => 10**-24
  }
  
  # class methods
  
  def self.[](arg)
#    @@list.select{|unit| unit.symbol == arg.to_s}.first
    self.parse(arg.to_s)
  end
  
  def self.[]=(key, arg)
    if Array === arg and arg.size == 2
      a = [key, arg.first]
      u = arg.last
    else
      a = [key]
      u = arg
    end
    @@list << (self === u ? u : self[u]).cast(*a)
  end
  
  def self.list
    @@list.map(&:symbol)
  end
  
  def self.<<(arg)
    if self === arg
      @@list << arg
    else
      @@list << Unit[arg]
    end
  end
  
  def self.assign
    @@list << self.new{|config| yield(config)}
  end
  
  def self.parse(unit_str)
    a = parse_1st(unit_str)
    (Array === a) ? parse_2nd(a) : a
  end
  
  def self.parse_1st(unit_str) # とても手続き的な書き方で禿げる
    u = @@list.select{|u| u.symbol == unit_str}.first
    return u if u
    
    return unit_str if unit_str =~ /^[\.\/]$/
    
    # 再帰で呼び出す用
    rec = ->(arg){__send__(__method__, arg)}
    
    a = unit_str.scan(/(?<=\().*(?=\))|[\.\/]|[^\(\)\.\/]+/)
    return a.map{|elem| rec[elem]} if a.size > 1
    
    m = unit_str.match(/\d+$/)
    return m.to_s if m and m.pre_match.empty?
    return [rec[m.pre_match], m.to_s] if m
    
    m = unit_str.match(/^(?<prefix>#{@@prefix.keys.join('|')})(?<unit>#{list.join('|')})$/)
    return rec[m[:unit]].cast(unit_str, @@prefix[m[:prefix]]) if m
    
    raise "No Unit Assigned: #{unit_str}"
  end
  
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
      when /^\d+$/
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
    config = Config.new
    yield(config) if block_given?
    config.compile
    
    @symbol = config.symbol
    @dimension = config.dimension
    @from_si = config.from_si
    @to_si = config.to_si
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
    (@dimension.keys || other_unit.dimension.keys).all?{|k|
      @dimension[k] == other_unit.dimension[k]
    }
  end
  
  
  def *(other_unit)
    opr = (other_unit.symbol[0] == '/') ? '': '.'
    
    self.class.new do |conf|
      @dimension.each{|k, v| conf.dimension[k] += v}
      other_unit.dimension.each{|k, v| conf.dimension[k] += v}
      
      conf.from_si = ->(x){other_unit.from_si(from_si(x))}
      conf.to_si = ->(x){other_unit.to_si(to_si(x))}
      
      @derivation.each{|k, v| conf.derivation[k] += v}
      other_unit.derivation.each{|k, v| conf.derivation[k] += v}
    end
  end
  
  def /(other_unit)
    self.class.new do |conf|
      @dimension.each{|k, v| conf.dimension[k] += v}
      other_unit.dimension.each{|k, v| conf.dimension[k] -= v}
      
      conf.from_si = ->(x){from_si(x) / (other_unit.from_si(1) - other_unit.from_si(0))}
      conf.to_si = ->(x){to_si(x) / (other_unit.to_si(1) - other_unit.to_si(0))}
      
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

