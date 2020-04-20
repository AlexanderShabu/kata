defmodule Intriangle do
  def get_b(a,c) do
    temp=4*c*c-3*a*a
    if temp > 0, do: ((:math.sqrt(temp)) - a)/2.0, else: -1  
  end
  def give_triang(per) do
    (for c <- 3..(per-6), a <- 3..(c-3) , b = get_b(a,c), b > 0, a > 0, Float.ceil(b) == Float.floor(b), a+b+c <= per, do: {c,a+b})
    |>Enum.uniq
    |>Enum.count()
  end
end