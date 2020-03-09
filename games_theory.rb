class Strategy
  def initialize()
  end
end
class Game
  
  def initialize(strategies = []) # [[stratx,straty,outcome], [stratx,straty,outcome]...]
    @strategiesx = []
    @strategiesy = [] 
    @outcomes = {}
    strategies.each do |strat|
      if !(@strategiesx.include?(strat[0]))
        @strategiesx.push(strat[0])
        @outcomes[strat[0]] = {}
      end
      if !(@strategiesy.include?(strat[1]))
        @strategiesy.push(strat[1])
      end
      @outcomes[strat[0]][strat[1]] = strat[2]
    end
    @outcomes
  end
  
  def self.randomize(rws,cls)
    strategiesx = []
    strategiesy = []
    for i in 0...rws
      strategiesx[i] = Strategy.new()
    end
    for j in 0...cls
      strategiesy[j] = Strategy.new()
    end
    outs = []
    strategiesx.each do |x|
      strategiesy.each do |y|
        outs.push([x,y,(rand(20) + rand(2) - 10)])
      end
    end
    Game.new(outs)
  end
  
  def map(dif)
    @strategiesx.each do |strx|
      @strategiesy.each do |stry|
        @outcomes[strx][stry] = @outcomes[strx][stry] + dif
      end
    end
  end
  
  def situation(strat1,strat2)
    @outcomes[strat1][strat2]
  end
  
  def display()
    row = ' '
    j = 1
    @strategiesy.each do |straty|
      row = row + '   ' + j.to_s
      j = j + 1
    end
    puts row
    row = '  .'
    @strategiesy.each do |straty|
      row = row + '___.'
    end
    puts row
    i = 1
    @strategiesx.each do |stratx|
      row = i.to_s + ' |'
      @strategiesy.each do |straty|
        if @outcomes[stratx][straty] >= 0
          row = row + ' '
        end
        if @outcomes[stratx][straty] != 10 && @outcomes[stratx][straty] != -10
          row = row + ' '
        end
        row = row + @outcomes[stratx][straty].to_s + '|'
      end
      puts row
      i = i + 1
    end
    row = '  `'
    @strategiesy.each do |straty|
      row = row + '````'
    end
    puts row
  end
  
  def lower_price()
    prcg = nil
    @strategiesx.each do |strx|
      prc = situation(strx,@strategiesy[0])
      @strategiesy.each do |stry|
        if situation(strx,stry) < prc
          prc = situation(strx,stry)
        end
      end
      if !prcg || prc > prcg
        prcg = prc
      end
    end
    prcg
  end
  
  def upper_price()
    prcg = nil
    @strategiesy.each do |stry|
      prc = situation(@strategiesx[0],stry)
      @strategiesx.each do |strx|
        if situation(strx,stry) > prc
          prc = situation(strx,stry)
        end
      end
      if !prcg || prc < prcg
        prcg = prc
      end
    end
    prcg
  end
  
  def equ_point_check()
    lower_price() === upper_price()
  end
  
  def max_min()
    prcg = nil
    maxmin = 0
    @strategiesx.each do |strx|
      prc = situation(strx,@strategiesy[0])
      @strategiesy.each do |stry|
        if situation(strx,stry) < prc
          prc = situation(strx,stry)
        end
      end
      if !prcg || prc > prcg
        prcg = prc
        maxmin = @strategiesx.index(strx)
      end
    end
    maxmin + 1
  end
  
  def strategy_i_outcomes(row)
    outs = []
    @strategiesy.each do |strat|
      outs.push(situation(@strategiesx[row],strat))
    end
    outs
  end
  
  def strategy_j_outcomes(col)
    outs = []
    @strategiesx.each do |strat|
      outs.push(situation(strat,@strategiesy[col]))
    end
    outs
  end
  
  def min_max()
    prcg = nil
    minmax = 0
    @strategiesy.each do |stry|
      prc = situation(@strategiesx[0],stry)
      @strategiesx.each do |strx|
        if situation(strx,stry) > prc
          prc = situation(strx,stry)
        end
      end
      if !prcg || prc < prcg
        prcg = prc
        minmax = @strategiesy.index(stry)
      end
    end
    minmax + 1
  end
  
  def brown_robinson(iterations = 20)
    if !equ_point_check()
      
      alpha = 0
      @strategiesx.each do |strx|
        @strategiesy.each do |stry|
          if situation(strx,stry) < -alpha
            alpha = 0 - situation(strx,stry)
          end
        end
      end
      map(alpha)
      choices = []
      choices[0] = []
      choices[1] = []
      accumulated = []
      accumulated[0] = []
      accumulated[1] = []
      @strategiesx.each do |out|
        choices[0].push(0)
        accumulated[1].push(0)
      end
      @strategiesy.each do |out|
        choices[1].push(0)
        accumulated[0].push(0)
      end
      i = max_min() - 1
      choices[0][i] = 1
      iterations.times do |time|
        x = 0
        strategy_i_outcomes(i).each do |out|
          accumulated[0][x] = accumulated[0][x] + out
          x = x + 1
        end
        j = accumulated[0].index(accumulated[0].min)
        choices[1][j] = choices[1][j] + 1
        x = 0
        strategy_j_outcomes(j).each do |out|
          accumulated[1][x] = accumulated[1][x] + out
          x = x + 1
        end
        if time < iterations - 1
          i = accumulated[1].index(accumulated[1].max)
          choices[0][i] = choices[0][i] + 1
        end
      end
      minprice = false
      maxprice = false
      @strategiesx.each do |stratx|
        price = 0
        @strategiesy.each do |straty|
          price = price + (choices[1][@strategiesy.index(straty)] * situation(stratx,straty))
        end
        if !maxprice || price > maxprice
          maxprice = price
        end
      end
      @strategiesy.each do |straty|
        price = 0
        @strategiesx.each do |stratx|
          price = price + (choices[0][@strategiesx.index(stratx)] * situation(stratx,straty))
        end
        if !minprice || price < minprice
          minprice = price
        end
      end
      out = {}
      out["price"] = [minprice.to_f/iterations,maxprice.to_f/iterations]
      out["choices"] = choices
      out
    end
  end
  
end

puts "first player strategies count:"
i = gets.to_i
stratsx = []
stratsy = []
gameset = []
iterations = 0
i.times do |x|
  tempstrat = Strategy.new()
  stratsx.push(tempstrat)
  puts "space separated outcomes for strategy " + (x+1).to_s + " of the first player:"
  outcomes = gets
  j = 0
  outcomes.split(' ').each do |out|
    if x === 0
      stratsy.push(Strategy.new())
    end
    gameset.push([tempstrat,stratsy[j],out.to_i])
    j = j + 1
  end
end
puts "iterations count:"
iterations = gets.to_i
game2 = Game.new(gameset)
game2.display()
puts game2.brown_robinson(iterations)