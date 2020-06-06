defmodule BestSum do
  
  def best_sum(t, k, ls) do
    m = ls |> Enum.sort
    {res,sum} = iterate( m, t , k, 0, 1)
    sum
  end
 
  defp iterate( [], t , k,  c_sum, num_iter) , do: {:fail,nil}
  defp iterate( m, t , k,  c_sum, num_iter) when num_iter == k do
    sum = m |> Enum.reduce_while(0, fn x, acc -> if x+c_sum <= t , do: {:cont,Kernel.max(x+c_sum,acc)}, else: {:halt,Kernel.max(c_sum,acc)} end)
    if sum == 0 || sum == c_sum, do: {:fail,nil}, else: {:ok,sum}
   end
 
  defp iterate( [head|tail], t , k,  c_sum, num_iter) do
    {x,sum}=[head|tail]
     |> Enum.reduce_while({tail,0}, fn x, {arr,max_sum} ->
          if length(arr) > 0 do
            {res,sum}=iterate(arr ,t, k, c_sum+x, num_iter + 1) 
 
            if length(arr)>=1 && res == :ok do
              {:cont,{arr|>tl,Kernel.max(sum,max_sum)}}
            else
              {:halt,{arr,max_sum}}
            end
          else
            {:halt,{arr,max_sum}}
          end
       end)
    {:ok,sum}
  end
end
