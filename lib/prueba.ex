defmodule Prueba do
  alias :mnesia, as: Mnesia

  def generate_tables do
    Mnesia.create_schema([node()])
    Mnesia.start()
    Mnesia.create_table(Caller, attributes: [:id, :call_number])
    Mnesia.create_table(Organizer, attributes: [:id, :current_calls])
    Mnesia.create_table(Phones, attributes: [:id, :process])
  end

  def start_lottery(winner_call, number_of_calls) do
    reset_db
    generate_tables
    Mnesia.transaction(fn ->
      Mnesia.write({Organizer, 1, 0})
      Mnesia.write({Phones, 1, spawn(fn -> 1 end)})
      Mnesia.write({Phones, 2, spawn(fn -> 2 end)})
      Mnesia.write({Phones, 3, spawn(fn -> 3 end)})
      Mnesia.write({Phones, 4, spawn(fn -> 4 end)})
    end)
    generate_calls(winner_call, number_of_calls, 1)
  end

  def generate_calls(winner_call, number_of_calls, current) do
    Mnesia.transaction(fn -> Mnesia.write({Caller, current, 0}) end)
    spawn(fn -> assign_call(winner_call, current) end)
    if(current < number_of_calls)do
      generate_calls(winner_call, number_of_calls, current + 1)
    end
    IO.write("")
  end

  def assign_call(winner_call, current) do
    telephone = :rand.uniform(4)
    make_call(telephone, winner_call, current)
  end

  def make_call(telephone, winner_call, current) do
    Mnesia.transaction(fn ->
      [{Phones, telephone, actual_process}] = Mnesia.read({Phones, telephone})

      if(!Process.alive?(actual_process)) do
        Mnesia.write({Phones, telephone, self()})
        make_transaction(winner_call, current)
        IO.inspect("Entro al telefono #{telephone}, la persona #{current}")
        check_winner(winner_call, current)
      else
        IO.inspect("Estoy esperando: #{telephone}, la persona #{current}")
        Process.sleep(:rand.uniform(500))
        assign_call(winner_call, current)
      end
    end)
  end

  def make_transaction(winner_call, current) do
    Mnesia.transaction(fn ->
      [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
      answer_call(actual_call + 1, current)
      Process.sleep(:rand.uniform(100))
    end)
  end

  def answer_call(actual_call, current) do
    Mnesia.write({Organizer, 1, actual_call})
    Mnesia.write({Caller, current, actual_call})
  end

  def check_winner(winner_call, current) do
    Mnesia.transaction(fn ->
      [{Caller, current, actual_call}] = Mnesia.read({Caller, current})

      cond do
        actual_call == winner_call ->
          [{Caller, current, winner}] = Mnesia.read({Caller, current})
          IO.puts("Felicidades ganó el caller: #{current}, con el numero de llamada: #{winner}")

        actual_call > winner_call ->
          [{Caller, current, winner}] = Mnesia.read({Caller, current})

          IO.puts(
            "Lo sentimos, ya hubo un ganador id: #{current}, tu numero de llamada fue #{winner}"
          )

        true ->
          [{Caller, current, winner}] = Mnesia.read({Caller, current})
          IO.puts(
            "Lo sentimos, siga intentando caller : #{current}, tu numero de llamada fue #{winner}"
          )
      end
    end)
  end

  def reset_db do
    Mnesia.delete_table(Organizer)
    Mnesia.delete_table(Caller)
    Mnesia.delete_table(Phones)
  end
end
