
defmodule Kata do
    require Integer
    def triangle(row) do
        x = for <<el <- row >> do 
            case el do 
                66 -> 2 
                71 -> 1
                82 -> 0 
            end
        end
        n=length x
        {sum,_} = Enum.reduce(x,{0,0},fn el,{s,k} ->
            r = if el == 0, do: 0, else: binomial_mod3(n-1,k)*el
            { Integer.mod(r+s,3), k+1 }
        end)
        p=if Integer.is_even(n), do: -1, else: 1
        Enum.at(["R","G","B"],Integer.mod(sum1*p,3))
    end
    defp binomial_mod3(0, k, res), do: res
    defp binomial_mod3(n, k, res\\1) do
        n3 = rem(n,3)
        k3 = rem(k,3)
        if k3 > n3 do
             0 
        else
          temp = if k3 == 0 or k3 == n3, do: 1 , else: 2
          res = rem(res * temp,3)
          n = n/3|>trunc
          k = k/3|>trunc
          binomial_mod3(n,k,res)
        end
    end

    def t() do
        {time, result} = :timer.tc(fn -> Enum.each(1..1000, fn num -> triangle("GRBGRRRBGRBGRGBRGBRRRGGGRRRBBBRRRGGGRBRGBRRGRBGRGBBGRGBRGBGRRGRRRBBBGGRRRGBBBGR") end) end)
        IO.puts "Time: #{time}ms"
        IO.puts "Result: #{result}"
      end
end
