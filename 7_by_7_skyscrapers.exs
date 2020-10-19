defmodule PuzzleSolver do
  @all [0,1,2,3,4,5,6]
  @floors [1,2,3,4,5,6,7]

  def solve(clues) do
    matrix = for _i <- 0..6, do: for _j <- 0..6, do: @floors 
    map=gen_variants(init_map())
    {matrix,stat}= Enum.reduce_while(1..10, {matrix,0}, fn _step, {matr,prev_status} ->
      matr=matr|>check_cell(clues,map)|>additional_check_cell()
      stat=status(matr)
      if prev_status != stat, do: {:cont,{matr,stat}}, else: {:halt,{matr,stat}}
    end)
    {matrix,stat}= Enum.reduce_while(1..10, {matrix,stat}, fn _step, {matr,prev_status} ->
      matr=matr|>check_cell2(clues)|>additional_check_cell()
      stat=status(matr)
      if prev_status != stat, do: {:cont,{matr,stat}}, else: {:halt,{matr,stat}}
    end)
    matrix=(if stat > 49, do: check_imit(matrix,clues), else: matrix) 
    Enum.reduce(matrix, [], fn row,matr-> matr++[List.flatten(row)] end)
  end

  defp check_imit(matrix,clues) do
    arr=init_model(matrix)
    Enum.reduce(arr,matrix, fn {r,c}, matr1 ->
      arr=Enum.at(matr1,r)|>Enum.at(c)
      Enum.reduce_while(arr, matr1, fn el, matr ->
        matr_temp=set_value(matr,r,c,el)
        {matr_temp,stat}= Enum.reduce_while(1..10, {matr_temp,0}, fn _step, {matr,prev_status} ->
          matr=matr|>check_cell2(clues)|>additional_check_cell()
          stat=status(matr)
          if prev_status != stat, do: {:cont,{matr,stat}}, else: {:halt,{matr,stat}}
        end)
        if stat < 49 do 
          {:cont,matr} 
        else if stat == 49, do:  {:halt,matr_temp}, else: {:cont,matr_temp}
        end
      end)
    end)
  end

  defp init_model(matrix) do
    Enum.reduce(0..6,[], fn r, arr -> 
      Enum.reduce(0..6, arr, fn c, a -> if length(Enum.at(matrix,r)|>Enum.at(c)) > 1, do: a++[{r,c}], else: a end)
    end)
  end

  defp status(matrix) do
     Enum.reduce(0..6,0, fn j, sum1 -> Enum.reduce(0..6,sum1, fn i, sum -> sum+length(Enum.at(matrix,j)|>Enum.at(i)) end) end)
  end

  defp check_cell2(matrix,clues) do
    Enum.reduce(0..3, matrix, fn step,matr -> 
      clues1=Enum.slice(clues,step*7..((step+1)*7-1))
      matr=Enum.reduce(0..6, matr, fn col, m -> 
        clue=Enum.at(clues1,col)
        if clue != 0 do
          map2 = init_map2(matr,col)
          arr=gen_variants2(map2,clue)
          m|>act_on_col(clue,col,arr)|>check_uniq(col)|>check_duplicates(col)
        else
          m
        end
      end)  
      matr|>rotate
    end)
  end

  defp check_cell(matrix,clues,map) do
    Enum.reduce(0..3, matrix, fn step,matr -> 
      clues1=Enum.slice(clues,step*7..((step+1)*7-1))
      matr=Enum.reduce(0..6, matr, fn col, m -> 
        clue=Enum.at(clues1,col)
        m|>act_on_col(clue,col,map[clue])|>check_uniq(col)|>check_duplicates(col)
      end)  
      matr|>rotate
    end)
  end

  defp additional_check_cell(matrix) do
    Enum.reduce(0..3, matrix, fn _step,matr -> 
         matr=Enum.reduce(0..6, matr, fn col, m -> 
         m|>check_uniq(col)|>check_duplicates(col)
      end)  
      matr|>rotate
    end)
  end

  defp act_on_col(matrix,clue_top,col,variants) when clue_top > 0 and clue_top <= 7, do: set_column(matrix,col, variants)
  defp act_on_col(matrix,_clue_top,_col,_variants), do: matrix
  defp check_duplicates(matrix,col) do
    Enum.reduce(1..7, matrix, fn val,m -> 
       row = get_row_for(m,col,val) 
       if row >= 0, do: m|>del_values(@all--[row],[col],val)|>del_values([row],@all--[col],val), else: m 
     end)
  end

  defp check_uniq(matrix,col) do
     Enum.reduce(1..7, matrix, fn val,m -> 
      {num_val,row} = Enum.reduce(0..6, {0,0}, fn row, {num,r} -> 
        a=Enum.at(m,row)|>Enum.at(col)
        if Enum.member?(a,val), do: {num+1,row}, else: {num,r}
      end)
      if num_val == 1, do: set_value(m,row,col,val), else: m 
    end)
  end

  defp get_row_for(matrix, col, val) do
    Enum.reduce_while(0..6, -1, fn row, _ind -> 
        a=Enum.at(matrix,row)|>Enum.at(col)
        if length(a) == 1 && Enum.at(a,0) == val, do: {:halt,row}, else: {:cont,-1} 
      end)
  end

  defp del_value(matrix,row,col,value) do
    r=Enum.at(matrix,row)
    r=List.replace_at(r,col,Enum.at(r,col)--[value])
    List.replace_at(matrix,row,r)
  end
  defp del_values(matrix,rows,cols,value) do
    Enum.reduce(rows, matrix, fn row, matr1 -> 
      Enum.reduce(cols, matr1, fn col, matr2 -> del_value(matr2,row,col,value) end )
    end)
  end
  defp set_column(matrix,col, arr) do
     m=Enum.reduce( 0..6, matrix, fn row, matr ->
      r=Enum.at(matr,row)
      c=Enum.at(r,col)
      if length(c)>length(Enum.at(arr,row)) do 
        r=List.replace_at(r,col,intersect(c,Enum.at(arr,row)))
        List.replace_at(matr,row,r)
      else matr
      end
     end)
     m
  end
  defp intersect(a1,a2) do
     Enum.reduce( a1, [], fn el,arr->
        if Enum.member?(a2,el), do: arr++[el], else: arr
     end) 
  end
  defp set_value(matrix,row,col,value) do
    r=Enum.at(matrix,row)|>List.replace_at(col,[value])
    List.replace_at(matrix,row,r)
  end
  defp init_map2(m,col) do
    Enum.at(m,0)|>Enum.at(col)
    for a<-Enum.at(m,0)|>Enum.at(col),b<-Enum.at(m,1)|>Enum.at(col),c<-Enum.at(m,2)|>Enum.at(col),d<-Enum.at(m,3)|>Enum.at(col),
        e<-Enum.at(m,4)|>Enum.at(col),f<-Enum.at(m,5)|>Enum.at(col),j<-Enum.at(m,6)|>Enum.at(col),
        a not in [b,c,d,e,f,j], b not in [c,d,e,f,j], c not in [d,e,f,j], d not in [e,f,j], e not in [f,j], f != j,  do: [a,b,c,d,e,f,j]
  end  
  defp gen_variants2(map,clue) do
    Enum.reduce(map,[], fn el, m -> if get_vis(el) ==clue, do: m++[el], else: m end)|> merge
  end
  
  defp init_map do
    for a <- 1..7, b <- 1..7, c <- 1..7, d <- 1..7, e <- 1..7, f <- 1..7, j <- 1..7, 
      a not in [b,c,d,e,f,j], b not in [c,d,e,f,j], c not in [d,e,f,j], d not in [e,f,j], e not in [f,j], f != j,  do: [a,b,c,d,e,f,j]
  end
  defp gen_variants(a) do
      map=Enum.reduce(a,%{1=>[],2=>[],3=>[],4=>[],5=>[],6=>[],7=>[]}, fn el, m -> 
        vis = get_vis(el) 
        {_old,m}=Map.get_and_update(m,vis, fn cur -> {cur, cur++[el]} end)
        m
      end)
      Enum.reduce(1..7,map, fn key,m -> 
        {_,m}=Map.get_and_update(m,key, fn arr -> {arr,merge(arr)} end) 
        m 
      end)
  end
  defp get_vis(arr) do
      {_,vis,_} = Enum.reduce(arr, {0,0,0}, fn el,{prev,vis,max} -> comp(el,prev,vis,max) end)
      vis
  end
  defp comp(el,prev,vis,max) when el <= prev or el < max , do: {el,vis,max}
  defp comp(el,prev,vis,max) when el > prev and el > max , do: {el,vis+1,el}
  def merge(a_in) do
    Enum.reduce(a_in,[[],[],[],[],[],[],[]], fn el, arr -> 
        Enum.reduce(0..6, arr, fn ind, a ->
         List.replace_at(a,ind,Enum.at(a,ind)++[Enum.at(el,ind)]|>Enum.uniq|>Enum.sort) end  )
    end)
  end
  defp rotate(matrix), do: matrix |> Enum.zip |> Enum.map(fn t -> :erlang.tuple_to_list(t) end) |> Enum.reverse
end


#clues=[ 7,0,0,0,2,2,3,  0,0,3,0,0,0,0,  3,0,3,0,0,5,0,  0,0,0,0,5,0,4 ]
#clues=[ 0,2,3,0,2,0,0,  5,0,4,5,0,4,0,  0,4,2,0,0,0,6,  5,2,2,2,2,4,1]
#clues=[ 6,4,0,2,0,0,3,  0,3,3,3,0,0,4,  0,5,0,5,0,2,0,  0,0,0,4,0,0,3 ]

#clues=[ 3,3,2,1,2,2,3,  4,3,2,4,1,4,2,  2,4,1,4,5,3,2,  3,1,4,2,5,2,3]