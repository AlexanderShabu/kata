defmodule Kata do
    def list_position(word), do: list_pos(String.codepoints(word))
    defp list_pos([]), do: 1
    defp list_pos(arr=[first|tail]) do
            calc(sort_arr(arr),length(tail))*count_less(first,tail) + list_pos(tail)
    end
    defp calc(sorted_arr,m), do: Enum.reduce(sorted_arr, f(m), fn {_,num}, mult -> mult/f(num) end)   
    defp count_less(letter, tail), do: Enum.reduce(tail,0, fn x, sum -> if x < letter, do: sum+1, else: sum end)
    defp sort_arr(arr), do: arr |> Enum.sort |> Enum.chunk_by(&(&1)) |> Enum.map(fn x-> {Enum.at(Enum.dedup(x),0),length(x)} end)  
    defp f(0), do: 1
    defp f(n) when n > 0, do: n * f(n - 1)
end
# "QUESTION" 24572
# "BAAA" - 4
# "YBFDQHPFJUEGJQWVQKTUHZ" - 10646552331519606273
# BOOKKEEPER - 10743