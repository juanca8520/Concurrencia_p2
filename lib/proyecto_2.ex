defmodule Proyecto_2 do
  alias :mnesia, as: Mnesia

  def generate_tables do
    Mnesia.create_schema([node()])
    Mnesia.start()
    Mnesia.create_table(Caller, attributes: [:id, :call_number])
    Mnesia.create_table(Organizer, attributes: [:id, :current_calls])
  end

  def start_lottery(winner_call, number_of_calls) do
    Mnesia.transaction(fn ->
      Mnesia.write({Organizer, 1, 0})
    end)

    generate_calls(winner_call, number_of_calls, 1)
  end

  def generate_calls(winner_call, number_of_calls, current) when current == number_of_calls do
    IO.puts("Finished")
  end

  def generate_calls(winner_call, number_of_calls, current) when current < winner_call do
    Mnesia.transaction(fn -> Mnesia.write({Caller, current, 0}) end)
    spawn(fn -> assign_call(winner_call, current + 1) end)
    generate_calls(winner_call, number_of_calls, current + 1)
  end

  def generate_calls(winner_call, number_of_calls, current) when current >= winner_call do
    Mnesia.transaction(fn -> Mnesia.write({Caller, current, 0}) end)
    spawn(fn -> assign_call(winner_call, current + 1) end)
    generate_calls(winner_call, number_of_calls, current + 1)
  end

  def assign_call(winner_call, current) do
    telephone = :rand.uniform(4)

    case telephone do
      1 ->
        Mnesia.transaction(fn ->
          [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
          answer_call(actual_call + 1, winner_call, current)
        end)

      2 ->
        spawn(fn ->
          Mnesia.transaction(fn ->
            [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
            answer_call(actual_call + 1, winner_call, current)
          end)
        end)

      3 ->
        spawn(fn ->
          Mnesia.transaction(fn ->
            [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
            answer_call(actual_call + 1, winner_call, current)
          end)
        end)

      4 ->
        spawn(fn ->
          Mnesia.transaction(fn ->
            [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
            answer_call(actual_call + 1, winner_call, current)
          end)
        end)
    end
  end

  def answer_call(actual_call, winner_call, current) do
    Mnesia.write({Organizer, 1, actual_call})
    [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
    Mnesia.write({Caller, actual_call, current})


    if actual_call == winner_call do
      [{Caller, actual_call, winner}] = Mnesia.read({Caller, actual_call})
      IO.puts("Felicidades ganó el caller con el id: #{winner}")
      nil
    end
    if actual_call < winner_call do
      [{Caller, actual_call, winner}] = Mnesia.read({Caller, actual_call})
      IO.puts("Lo sentimos, siga intentando id: #{winner}")
    else 
      [{Caller, actual_call, winner}] = Mnesia.read({Caller, actual_call})
      IO.puts("Lo sentimos, ya hubo un ganador id: #{winner}")
    end
  end

  def read_db do
    Mnesia.transaction(fn -> Mnesia.read({Organizer, 1}) end)
  end

  def reset_db do
    Mnesia.delete_table(Organizer)
    Mnesia.delete_table(Caller)
  end
end
