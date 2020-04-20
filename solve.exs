defmodule Solv do
    def solve(m) do
      a = m
      b = (-1.0-2.0*m)
      c = m
      d = b*b - 4.0*a*c
      x1 = (-b-:math.sqrt(d))/(2.0*a)
      x2 = (-b+:math.sqrt(d))/(2.0*a)
      Kernel.min(x1,x2)
    end
end