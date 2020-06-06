
defmodule PokerHand do
    @result %{win: 1, loss: 2, tie: 3}
    @funcs [
        {&PokerHand.royal_flush/3,9},
        {&PokerHand.straight_flush/3,8},
        {&PokerHand.four_of_a_kind/3,7},
        {&PokerHand.full_house/3,6},
        {&PokerHand.flash/3,5},
        {&PokerHand.straight/3,4},
        {&PokerHand.three_of_a_kind/3,3},
        {&PokerHand.two_pairs/3,2},
        {&PokerHand.pair/3,1},
        {&PokerHand.high_card/3,0},
    ]
    @suits %{ "S" => 0, "H" => 1, "D" => 2, "C" => 3}
    @values %{ "2"=>2,"3"=>3,"4"=>4,"5"=>5,"6"=>6,"7"=>7,"8"=>8,"9"=>9,"T"=>10,"J"=>11,"Q"=>12,"K"=>13,"A"=>14}

    def compare(player, opponent) do
      {cat1,values1} = player |> transform |> hands_value  
      {cat2,values2} = opponent |> transform |> hands_value  
      if cat1 > cat2 do @result.win
      else if cat1 < cat2, do: @result.loss, else: compare_details(values1, values2) end   
    end
    def compare_details(values1, values2) do
      Enum.reduce_while( 0..4, @result.tie, fn ind, _acc -> 
                      if Enum.at(values1,ind) > Enum.at(values2,ind) do
                        {:halt, @result.win}
                      else if Enum.at(values1,ind) < Enum.at(values2,ind), do: {:halt, @result.loss}, else: {:cont,@result.tie}
                      end
                    end)  
    end
    def transform( cards ) do
      String.split(cards," ") |> Enum.map( fn x -> {@values[String.at(x,0)],@suits[String.at(x,1)]} end)  
    end
    def hands_value( cards_map ) do
      s = group_by_suits(cards_map)
      v = group_by_value(cards_map)
      Enum.reduce_while(@funcs, 0, fn {func,cat}, _acc -> func.(s,v,cat) end)
    end
    def group_by_suits(cards), do: Enum.reduce(cards,%{},fn {val,suit}, acc -> Map.merge(acc,%{suit=>[val]}, fn _k, v1,v2 -> v1++v2 end) end)         
    def group_by_value(cards), do: Enum.reduce(cards,%{},fn {val,suit}, acc -> Map.merge(acc,%{val=>[suit]}, fn _k, v1,v2 -> v1++v2 end) end)         
 
    def royal_flush(s,v,cat) do
      if Enum.count(s) == 1 do
        vals= Map.values(s)|>List.flatten|>Enum.sort
        if Enum.at(vals,4)-Enum.at(vals,0) == 5 && Enum.at(vals,0) == 10, do: {:halt,{cat,[]}}, else: {:cont,{-1,[]}}
      else
        {:cont,{-1,[]}}
      end
    end
    def straight_flush(s,v,cat) do
      if Enum.count(s) == 1 do
        vals= Map.values(s)|>List.flatten|>Enum.sort(&(&1 >= &2))
        {seq,_}=Enum.reduce_while(vals,{true,0}, fn val, {_,prev} -> 
                if prev == val+1 || (prev == 14 && val == 2) || prev == 0, do: {:cont,{true,val}}, else: {:halt,{false,val}} end)
        if seq , do: {:halt,{cat,vals}}, else: {:cont,{-1,[]}}
      else
        {:cont,{-1,[]}}
      end
    end
    def four_of_a_kind(s,v,cat) do
      x = Enum.map(v,fn {v,suits} -> if length(suits) > 1, do: v*length(suits)*10, else: v end)|>Enum.sort(&(&1 >= &2))
      map = Enum.map(v,fn {val, suites} -> {val,length(suites)} end)
      {val,num} = Enum.reduce(map,{0,0}, fn {cur_val,num1}, {max_val,num_max} -> if num1>num_max, do: {cur_val,num1}, else: {max_val,num_max} end)
      if num == 4, do: {:halt,{cat,x}}, else: {:cont,{-1,[]}} 
    end
    def full_house(s,v,cat) do
      if Enum.count(v) == 2 do 
        vals= Map.values(s)|>List.flatten|>Enum.sort(&(&1 >= &2))
        x = Enum.map(v,fn {v,suits} -> if length(suits) > 1 , do: v*length(suits)*10, else: v end)|>Enum.sort(&(&1 >= &2))
        {:halt,{cat,x}} 
      else 
        {:cont,{-1,[]}}
      end 
    end
    def flash(s,v,cat) do
      if Enum.count(s) == 1 do
        vals= Map.values(s)|>List.flatten|>Enum.sort(&(&1 >= &2))
        {:halt,{cat,vals}}
      else
        {:cont,{-1,[]}}
      end
    end
    def straight(s,v,cat) do
 #     vals=Map.keys(v)|>List.flatten|>Enum.sort
      if Enum.count(v) == 5 do
        vals= Map.values(s)|>List.flatten|>Enum.sort(&(&1 >= &2))
        {seq,_}=Enum.reduce_while(vals,{true,0}, fn val, {_,prev} -> 
            if prev == val+1 || (prev == 14 && val == 2) || prev == 0, do: {:cont,{true,val}}, else: {:halt,{false,val}} end)
        if seq , do: {:halt,{cat,vals}}, else: {:cont,{-1,[]}}
      else
        {:cont,{-1,[]}}
      end
    end
    def three_of_a_kind(s,v,cat) do
      map = Enum.map(v,fn {val, suites} -> {val,length(suites)} end)
      {val,num} = Enum.reduce(map,{0,0}, fn {cur_val,num1}, {max_val,num_max} -> if num1>num_max, do: {cur_val,num1}, else: {max_val,num_max} end)
      if num == 3 do
        x = Enum.map(v,fn {v,suits} -> if length(suits) > 1, do: v*length(suits)*10, else: v end)|>Enum.sort(&(&1 >= &2))
        {:halt,{cat,x}} 
      else {:cont,{-1,[]}} 
      end
   end
    def two_pairs(s,v,cat) do
      if Enum.count(v) == 3 do 
        x = Enum.map(v,fn {v,suits} -> if length(suits) == 2, do: v*20, else: v end)|>Enum.sort(&(&1 >= &2))
        {:halt,{cat,x}} 
      else 
        {:cont,{-1,[]}} 
      end
    end
    def pair(s,v,cat) do
      map = Enum.map(v,fn {val, suites} -> {val,length(suites)} end)
      {val,num} = Enum.reduce(map,{0,0}, fn {cur_val,num1}, {max_val,num_max} -> if num1>num_max, do: {cur_val,num1}, else: {max_val,num_max} end)
      sum = Enum.reduce(map,0, fn {cur_val,num1}, acc -> if num1 == 2 , do: acc+cur_val*10, else: acc+cur_val end)
      if num == 2 do
        x = Enum.map(v,fn {v,suits} -> if length(suits) == 2, do: v*20, else: v end)|>Enum.sort(&(&1 >= &2))
        {:halt,{cat,x}} 
      else
        {:cont,{-1,[]}}
      end
    end
    def high_card(s,v,cat) do
      vals= Map.values(s)|>List.flatten|>Enum.sort(&(&1 >= &2))
      {:halt,{cat,vals}}
    end
end

