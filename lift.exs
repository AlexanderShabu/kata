# The kata "The Lift"
defmodule Kata do
    def the_lift(queues, capacity) do
        lift(0,[],List.duplicate(0,length(queues)),split_queues(queues),capacity,length(queues),1) |> Enum.dedup
    end
    def lift(floor, stops, insiders, queues, capacity, num_floors, up_down) when floor == num_floors-1 and up_down == 1 do
        lift(floor, stops, insiders, queues, capacity, num_floors,-1)       
    end
    def lift(floor, stops, insiders, queues, capacity, num_floors, up_down) when floor < 0 and up_down == -1 do 
        lift(floor+1, stops, insiders, queues, capacity, num_floors, 1)
    end   
    def lift(floor, stops, insiders, queues, capacity, num_floors, up_down) do 
        if queue_size(queues) == 0 && Enum.sum(insiders) == 0 do
            if Enum.at(stops,-1) == 0, do: stops, else: stops ++ [0] 
        else
            out = Enum.at(insiders,floor) 
            n_insiders = ( if out > 0, do: List.update_at(insiders,floor,&(&1 - out)) ,else: insiders)               
            {passers,n_queues, stop} = get_passers(queues,floor,capacity-Enum.sum(n_insiders), up_down) 
            n_insiders = Enum.reduce(passers,n_insiders, fn el, insiders -> List.update_at(insiders,el,&(&1 + 1)) end)           
            n_stops = (if stop || out > 0 || length(passers)>0 || length(stops) == 0, do: stops ++ [floor], else: stops) 
            lift(floor+up_down, n_stops, n_insiders, n_queues, capacity, num_floors, up_down) 
        end
   end
    defp get_passers(queues, floor, max, up_down) when up_down == -1 do  
       {up,down} = Enum.at(queues,floor)  
       stop = (if length(down) > 0, do: true, else: false) 
       {n_down,down} = Enum.split(down,max)
       {n_down,List.replace_at(queues,floor,{up,down}), stop}
    end
    defp get_passers(queues, floor, max, up_down) when up_down == 1 do  
       {up,down} = Enum.at(queues,floor) 
       stop = (if length(up) > 0, do: true, else: false) 
       {n_up,up} = Enum.split(up,max)
       {n_up,List.replace_at(queues,floor,{up,down}), stop}
    end
    defp split_queues(queues), do: for {arr,ind} <- Enum.with_index(queues), do: Enum.split_with(arr, fn val -> val > ind end) 
    defp queue_size(queue), do: Enum.reduce(queue,0, fn {a1,a2}, acc -> acc + length(a1)+length(a2) end)
end

