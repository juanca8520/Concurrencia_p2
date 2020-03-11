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
    Process.sleep(:rand.uniform(500))
    telephone = :rand.uniform(4)

    case telephone do
      1 ->
        spawn(fn ->
          Mnesia.transaction(fn ->
            [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
            answer_call(actual_call + 1, winner_call, current)
          end)

          check_winner(winner_call, current)
        end)

      2 ->
        spawn(fn ->
          Mnesia.transaction(fn ->
            [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
            answer_call(actual_call + 1, winner_call, current)
          end)

          check_winner(winner_call, current)
        end)

      3 ->
        spawn(fn ->
          Mnesia.transaction(fn ->
            [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
            answer_call(actual_call + 1, winner_call, current)
          end)

          check_winner(winner_call, current)
        end)

      4 ->
        spawn(fn ->
          Mnesia.transaction(fn ->
            [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
            answer_call(actual_call + 1, winner_call, current)
          end)

          check_winner(winner_call, current)
        end)
    end
  end

  def answer_call(actual_call, winner_call, current) do
    Mnesia.write({Organizer, 1, actual_call})
    # [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
    Mnesia.write({Caller, current, actual_call})
  end

  def check_winner(winner_call, current) do
    Mnesia.transaction(fn ->
      [{Caller, current, actual_call}] = Mnesia.read({Caller, current})

      IO.puts("#{actual_call} #{winner_call}")

      if actual_call == winner_call do
        [{Caller, current, winner}] = Mnesia.read({Caller, current})
        IO.puts("Felicidades ganó el caller con el id: #{winner}")
      else
        [{Caller, current, winner}] = Mnesia.read({Caller, current})
        IO.puts("Lo sentimos, siga intentando id: #{winner}")
      end

      if actual_call > winner_call do
        [{Caller, current, winner}] = Mnesia.read({Caller, current})
        IO.puts("Lo sentimos, ya hubo un ganador id: #{winner}")
      end
    end)
  end

  def read_db do
    Mnesia.transaction(fn -> Mnesia.read({Organizer, 1}) end)
  end

  def reset_db do
    Mnesia.delete_table(Organizer)
    Mnesia.delete_table(Caller)
  end
end
