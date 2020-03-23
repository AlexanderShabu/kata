defmodule Directions do
# Kata Directions Reduction
  def reduce(directions), do: red([],directions)
  defp red(start,[el1|[el2|tail]]) do
    if opposite(el1,el2), do: red([],start ++ tail), else: red(start ++ [el1],[el2] ++ tail)
  end
  defp red(start,[el]), do: start ++ [el]
  defp red(start,[]), do: start
  defp opposite(el1,el2) when (el1 == "NORTH" and el2 == "SOUTH") or (el2 == "NORTH" and el1 == "SOUTH"), do: true 
  defp opposite(el1,el2) when (el1 == "WEST" and el2 == "EAST") or (el2 == "WEST" and el1 == "EAST"), do: true 
  defp opposite(el1,el2), do: false

end