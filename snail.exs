defmodule Snail do

  @doc """

  Converts a matrix to a list by walking around its edges from the top-left going clockwise.

  ![snail walk](http://www.haan.lu/files/2513/8347/2456/snail.png)

  iex> Snail.snail( [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ] )
  [ 1, 2, 3, 6, 9, 8, 7, 4, 5 ]

  """

  #@spec snail( [ [ term ] ] ) :: [ term ]
  def snail(matrix), do: fun(matrix,[])
  def fun([], res), do: res
  def fun( [first|tail], res ) do
    t=Enum.reverse(transpose( tail ))
    fun(t, res ++ first)
  end
  
  def transpose([]), do: []
  def transpose([[]|_]), do: []
  def transpose(list), do: [Enum.map(list, &hd/1) | transpose(Enum.map(list, &tl/1))]

 end
