defmodule PuzzleSolver do
  def solve(clues) do
    matrix = for i <- 0..3, do: for j <- 0..3, do: [1,2,3,4] 
    matrix = Enum.reduce(0..3, matrix, fn j,matr ->
      matr = Enum.reduce(0..3, matr, fn i, m -> 
        check_cell(m,clues,j,i) end)
     end)
    matrix = Enum.reduce(0..3, matrix, fn j,matr ->
      matr = Enum.reduce(0..3, matr, fn i, m -> 
        check_cell(m,clues,j,i)|>check_uniq(i) end)
      end)
 
    Enum.reduce(matrix, [], fn row,matr->
      r=List.flatten row
      matr= matr++[r]
    end)
  end
  defp check_cell(matrix,clues,row,col) do
    Enum.reduce(0..3, matrix, fn step,matr -> 
       clues1=Enum.slice(clues,step*4..((step+1)*4-1))
       {row,col}=conv(row,col)
       matr=matr|>act_on_top(Enum.at(clues1,col),row,col)|>check_uniq(col)|>check_duplicates(col)|>rotate
    end)  
  end
  
  def act_on_top(matrix,clue_top,row,col) when clue_top == 1 do
     matrix|>set_value(0,col,4)|>del_values([0],[0,1,2,3]--[col],4)|>del_values([1,2,3],[col],4)
  end
  def act_on_top(matrix,clue_top,row,col) when clue_top == 4 do
    matrix|>set_value(0,col,1)|>set_value(1,col,2)|>set_value(2,col,3)|>set_value(3,col,4) 
  end 
  def act_on_top(matrix,clue_top,row,col) when clue_top == 2 do
    matrix=matrix|>del_values([0],[col],4)
    matrix =(if get_row_for(matrix,col,4) == 3, do: set_value(matrix,0,col,3), else: matrix)
    matrix =(if get_row_for(matrix,col,4) == 2, do: matrix|>del_values([1],[col],3), else: matrix)
    matrix =(if get_row_for(matrix,col,4) == 2 && get_row_for(matrix,col,3) == 3, do: matrix|>set_value(0,col,2), else: matrix)
  end
  def act_on_top(matrix,clue_top,row,col) when clue_top == 3 do
    matrix=matrix|>del_values([0,1],[col],4) 
    matrix =(if get_row_for(matrix,col,4) >= 2, do: matrix|>del_values([0],[col],3), else: matrix)
    matrix =(if get_row_for(matrix,col,4) == 3 && get_row_for(matrix,col,3) == 2, do: matrix|>set_value(0,col,2), else: matrix)
    matrix =(if get_row_for(matrix,col,4) == 2 && get_row_for(matrix,col,3) == 3, do: matrix|>set_value(0,col,1), else: matrix)
  end
  def act_on_top(matrix,clue_top,row,col) when clue_top == 0 do
    matrix
  end
 def check_duplicates(matrix,col) do
    Enum.reduce(1..4, matrix, fn val,m -> 
       row = get_row_for(m,col,val) 
       m=(if row >= 0, do: del_values(m,[0,1,2,3]--[row],[col],val), else: m) end)
  end
  def check_uniq(matrix,col) do
    Enum.reduce(1..4, matrix, fn val,m -> 
      {num_val,row} = Enum.reduce(0..3, {0,0}, fn row, {num,r} -> 
        a=Enum.at(m,row)|>Enum.at(col)
        if Enum.member?(a,val), do: {num+1,row}, else: {num,r}
      end)
      m=(if num_val == 1, do: set_value(m,row,col,val), else: m) 
    end)
  end
  def get_row_for(matrix, col, val) do
    Enum.reduce_while(0..3, -1, fn row, ind -> 
        a=Enum.at(matrix,row)|>Enum.at(col)
        if length(a) == 1 && Enum.at(a,0) == val, do: {:halt,row}, else: {:cont,-1} 
      end)
   end
  def set_value(matrix,row,col,value) do
    r=Enum.at(matrix,row)|>List.replace_at(col,[value])
    List.replace_at(matrix,row,r)
  end

  def del_value(matrix,row,col,value) do
    r=Enum.at(matrix,row)
    r=List.replace_at(r,col,Enum.at(r,col)--[value])
    List.replace_at(matrix,row,r)
  end

  def del_values(matrix,rows,cols,value) do
    Enum.reduce(rows, matrix, fn row, matr1 -> 
      Enum.reduce(cols, matr1, fn col, matr2 -> del_value(matr2,row,col,value) end )
    end)
  end

  defp conv(row,col) do
    a=%{{0,0}=>{3,0},{0,1}=>{2,0},{0,2}=>{1,0},{0,3}=>{0,0},
        {1,0}=>{3,1},{1,1}=>{2,1},{1,2}=>{1,1},{1,3}=>{0,1},
        {2,0}=>{3,2},{2,1}=>{2,2},{2,2}=>{1,2},{2,3}=>{0,2},
        {3,0}=>{3,3},{3,1}=>{2,3},{3,2}=>{1,3},{3,3}=>{0,3},
       }
  a[{row,col}]
  end

  defp rotate(matrix), do: matrix |> Enum.zip |> Enum.map(fn t -> :erlang.tuple_to_list(t) end) |> Enum.reverse
end
