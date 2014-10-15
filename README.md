ruby-numeric-with-unit
======================
単位付き数値を提供します。したいです。


使い方
======================

	require 'nwu'

	#例1
	length = NumericWithUnit.new(10, 'm') #10[m]を表すオブジェクトです。
	puts length #=> 10 m
	puts length['cm'] #=> 100 cm

	time = 10.to_nwu('s') #Fixnum#to_nwuが追加されるので、これを用いてもOKです。10[s]を表すオブジェクトです。
	puts time #=>  10 s
	puts time['min'] #=> 0.16666666666666666 min

	speed = length / time
	puts speed #=> 1 m/(s)
	puts speed['km/hr'] #=> 3.6 km/(hr)

	require 'nwu/util' #自然な表記で記述できるようにします。
	puts (10['m'] / 10['s'] )['km/hr'] #=> 3.6 km/(hr)

	#例2
	puts (50['L/min'] + 3['m3/hr'] ) * 30['min'] #=> 3000 L


* `require 'nwu/util'`すると`Numeric#[]`と`Fixnum#[]`と`Bignum#[]`がオーバーライドされます。注意。


class Unit
======================
"単位"を表すクラスです。

Unit.new
----------------------

    km = Unit.new do |conf|
      conf.symbol = 'km'
      conf.dimension[:L] = 1
      conf.from_si{|x| x/1000}
      conf.to_si{|x| x*1000}
    end

`conf.from_si`と`conf.to_si`で、SI基本単位で表した場合の変換式を設定します。

Unit#cast
----------------------
1 mi = 1.609344 km  
のような関係の単位は、

    mi = km.cast('mi', 1.609344)

で生成できます。  
ただし、n倍だけの関係に限ります。
℃と℉のような関係の場合は`Unit.new`で新たに生成して下さい。

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
     
    puts Unit['km2'].symbol　#=> km2
    puts Unit['km/hr'].symbol　#=> km/(hr)

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

単位換算したり足したり引いたり掛けたり割ったり累乗したりできます。

NumericWithUnit.new(value, unit)
----------------------
valueの数値とunitの単位を持つNumericWithUnitオブジェクトを返します。
unitには単位を表す文字列またはUnitクラスのオブジェクトを渡します。

Numeric#to_nwu(unit), Fixnum#to_nwu(unit), Bignum#to_nwu(unit)
----------------------
NumericWithUnit.new(self, unit)を返します。

NumericWithUnit#value
----------------------
数値を返します。

NumericWithUnit#unit
----------------------
Unitオブジェクトを返します。

NumericWithUnit#\[\](new_unit), NumericWithUnit#to_nwu(new_unit)
----------------------
new_unitに変換したNumericWithUnitオブジェクトを返します。

selfと次元の異なる単位を指定した場合は、NumericWithUnit::DimensionErrorが発生します。

NumericWithUnit#+(other), NumericWithUnit#-(other)
----------------------
otherがNumericWithUnitクラスの場合、selfの単位に変換し数値を加減したNumericWithUnitオブジェクトを返します。  
otherがNumericWithUnitクラスでない場合、otherを無次元のNumericWithUnitにした上で加減します。

ohterとselfの次元が異なる場合は、NumericWithUnit#DimensionErrorが発生します。

NumericWithUnit#*(ohter), NumerichWithUnit#/(other)
----------------------
otherがNumericWithUnitクラスの場合、selfとotherの組立単位を持つ、数値を乗除したNumericWithUnitオブジェクトを返します。  
otherがNumericWithUnitクラスでない場合、otherを無次元のNumericWithUnitにした上で乗除します。

NumericWithUnit#**(num)
----------------------
selfの単位をnum乗した組立単位を持つ、数値をnum乗したNumericWithUnitオブジェクトを返します。


単位を表す文字列のフォーマット
======================
Unit[]や、NumericWithUnit#[]には、単位を表す文字列を渡すことができます。
例を示します。

- m
- cm
- m2
- kW.hr
- kg/cm2
- m.s-1
- J/kg/K
- kcal/(hr.m2.℃)

先頭に接頭辞、末尾に指数をつけた基本単位を、"."または"/"で繋いだ形で表記します。
"()"で基本単位として括ることもできます。


