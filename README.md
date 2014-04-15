ruby-numeric-with-unit
======================
単位付き数値を提供します。したいです。


使い方
======================

    require 'nwu'
    a = NumericWithUnit[50, 'L/min']
    b = NumericWithUnit[3, 'm3/hr']
    puts x = a + b
    #=> 100 L/(min)
    c = NumericWithUnit[30, 'min']
    puts y = x * c
    #=> 3000 L
    puts y['m3']
    #=> 3 m3
     
    require 'nwu/util'
    puts (50['L/min'] + 3['m3/hr'] ) * 30['min']
    #=> 3000 L
    puts (50.L_min + 3.m3_hr) * 30.min
	#=> 3000 L

* `'require 'nwu/util'`した場合は、`Numeric#[]`と`Fixnum#[]`と`Bignum#[]`がオーバーライドされるので注意。


class Unit
======================
"単位"を表すクラスです。

Unit.new
----------------------

    km = Unit.new do |conf|
      conf.symbol = 'km'
      conf.dimension[:L] = 1
      conf.from_si = ->(x){x/1000}
      conf.to_si = ->(x){x*1000}
    end

`conf.from_si`と`conf.to_si`で、SI基本単位で表した場合の変換式を設定します。

Unit#cast
----------------------
1 mi = 1.609344 km  
のような関係の単位は、

    mi = km.cast('mi', 1.609344)

で生成できます。  
ただし、比例関係だけに限ります。  
℃と℉のような関係の場合は`Unit.new`で別に定義して下さい。

Unit<<, Unit[], Unit[]=
----------------------
`Unit << unit`で、`unit`を基本単位として登録します。  
基本単位として登録することで、`Unit[]`から組立単位が自動的に導出されます。

    Unit << km
    Unit << Unit.new do |conf|
      conf.symbol = 'hr'
      conf.dimension[:T] = 1
      conf.from_si{|x| x/60/60}
      conf.to_si{|x| x*60*60}
    end
     
    puts Unit['km2'].symbol
    #=> km2
    puts Unit['km/hr'].symbol
    #=> km/(hr)

基本単位として登録されている単位は、`Unit.list`で得られます。

また`Unit[]=`で単位の変換と基本単位として登録を同時に行えます。

    Unit['kph'] = 'km/hr'
    Unit['ua'] = 1.495978706916e8, 'm'

****
基本的な単位は以下のファイルで定義済みです。  
適宜`require`してください。
* 'nwu/base_unit' (SI単位、SI組立単位およびSI併用単位を定義。デフォルトで`require`されます。)
* 'nwu/common_unit'  (独断と偏見によりcommonと認定された単位。デフォルトで`require`されます。)
* 'nwu/cgs_unit' (未完成)
* 'nwu/imperial_unit' (未完成)
* 'nwu/natural_unit' (未完成)

class NumericWithUnit
======================
単位の情報を持った数値を表すクラスです。

    km = Unit['km']
    a = NumericWithUnit.new(100, km)

足したり引いたり掛けたり割ったりできます。
