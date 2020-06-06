# Finds the first pair of ints as judged by the index of the second value.
#
#  iex> sum_pairs( [ 10, 5, 2, 3, 7, 5 ], 10 )
#
#
#  { 3, 7 }
#
#
#

defmodule SumOfPairs do
def sum_pairs( ints, sum ) do
    {map,v1,v2}=ints|>Enum.reduce_while({%{},nil,nil}, fn val,{s,_,_} -> 
        if Map.get(s,sum-val), do: {:halt,{s,sum-val,val}}, else: {:cont,{Map.put(s,val,1),nil,nil}}
      end)
      if v1 == nil, do: nil, else: {v1,v2}
    end
end
