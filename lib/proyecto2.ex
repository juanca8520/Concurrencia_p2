defmodule Proyecto2 do
  alias :mnesia, as: Mnesia

  def generate_tables do
    Mnesia.create_schema([node()])
    Mnesia.start()
    Mnesia.create_table(Caller, attributes: [:id, :call_number])
    Mnesia.create_table(Organizer, attributes: [:id, :current_calls])
  end

  def start_lottery(winner_call, number_of_calls) do
    generate_calls(winner_call, number_of_calls)
  end

  def generate_calls(winner_call, number_of_calls) do
    Mnesia.transaction(fn -> Mnesia.write({Organizer, 1, 0}) end)
    generate_calls(number_of_calls, 0, winner_call)
  end

  def generate_calls(number_of_calls, current_call, winner_call)
      when current_call < number_of_calls do
    assign_call(current_call, winner_call)
    generate_calls(number_of_calls, current_call + 1, winner_call)
  end

  def generate_calls(number_of_calls, current_call, winner_call) do
    assign_call(current_call, winner_call)
    # IO.puts("voy en #{current_call}")
  end

  def assign_call(caller_id, winner_call) do
    telephone = :rand.uniform(4)

    case telephone do
      1 ->
        # IO.puts("#{caller_id} #{winner_call}")

        Mnesia.transaction(fn ->
          actual_call = get_actual_call(fn -> Mnesia.read({Organizer, 1}) end)
          # Mnesia.write({Caller, caller_id, actual_call})
          spawn(answer_call(caller_id, actual_call, winner_call))
        end)

      2 ->
        Mnesia.transaction(fn ->
          actual_call = get_actual_call(fn -> Mnesia.read({Organizer, 1}) end)

          # Mnesia.write({Caller, caller_id, actual_call})

          spawn(answer_call(caller_id, actual_call, winner_call))
        end)

      3 ->
        Mnesia.transaction(fn ->
          actual_call = get_actual_call(fn -> Mnesia.read({Organizer, 1}) end)

          # Mnesia.write({Caller, caller_id, actual_call})

          spawn(answer_call(caller_id, actual_call, winner_call))
        end)

      4 ->
        Mnesia.transaction(fn ->
          actual_call = get_actual_call(fn -> Mnesia.read({Organizer, 1}) end)
          # IO.puts("actual call #{actual_call}")
          # Mnesia.write({Caller, caller_id, actual_call})

          spawn(answer_call(caller_id, actual_call, winner_call))
        end)
    end
  end

  def get_actual_call(func) do
    [head | tail] = elem(Mnesia.transaction(func), 1)
    ret = elem(head, 1) + 1
    ret
  end

  def answer_call(caller_id, actual_call, winner_call) do
    # Mnesia.transaction(fn ->
    # IO.puts("#{actual_call} #{caller_id}")
    # Mnesia.write({Organizer, 1, actual_call})
    # IO.puts(Mnesia.read({Organizer, 1}))
    # Mnesia.write({Logs, caller_id, actual_call, winner_call})

    if actual_call == winner_call do
      IO.puts("Felicidades, ganó la llamada con id: #{caller_id}")
    else
      IO.puts("Lo sentimos, siga intentando")
    end

    # end)
  end

  def answer_call(caller_id, actual_call, winner_call) do
    IO.puts("Lo sentimos, ya hubo un ganador")
  end

  def read_db do
    Mnesia.transaction(fn -> Mnesia.read({Caller, 1}) end)
  end
end
