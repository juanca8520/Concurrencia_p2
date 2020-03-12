defmodule Prueba do
  alias :mnesia, as: Mnesia

  def generate_tables do
    Mnesia.create_schema([node()])
    Mnesia.start()
    Mnesia.create_table(Caller, attributes: [:id, :call_number])
    Mnesia.create_table(Organizer, attributes: [:id, :current_calls])
  end

  def start_lottery(winner_call, number_of_calls) do
    reset_db
    generate_tables
    Mnesia.transaction(fn ->
      Mnesia.write({Organizer, 1, 0})
    end)

    generate_calls(winner_call, number_of_calls, 1)
  end

  def generate_calls(winner_call, number_of_calls, current) do
    spawn(fn ->
      avaiable_phones = %{
        :p1 => spawn(fn -> 1 end),
        :p2 => spawn(fn -> 2 end),
        :p3 => spawn(fn -> 3 end),
        :p4 => spawn(fn -> 4 end)
      }

      #IO.inspect(avaiable_phones)

      assign_call = fn callback, avaiable_phones, current ->
        telephone = :rand.uniform(4)
        Mnesia.transaction(fn -> Mnesia.write({Caller, current, 0}) end)

        if current <= number_of_calls do
          cond do
            telephone == 1 and !Process.alive?(avaiable_phones.p1) ->
              p1_actual = make_transaction(winner_call, current)
              avaiable_phones = Map.replace!(avaiable_phones, :p1, p1_actual)
              IO.inspect("Entro al telefono 1, la persona #{current}")
              #IO.inspect(avaiable_phones)
              callback.(callback, avaiable_phones, current + 1)

            telephone == 2 and !Process.alive?(avaiable_phones.p2) ->
              p2_actual = make_transaction(winner_call, current)
              avaiable_phones = Map.replace!(avaiable_phones, :p2, p2_actual)
              IO.inspect("Entro al telefono 2, la persona #{current}")
              #IO.inspect(avaiable_phones)
              callback.(callback, avaiable_phones, current + 1)

            telephone == 3 and !Process.alive?(avaiable_phones.p3) ->
              p3_actual = make_transaction(winner_call, current)
              avaiable_phones = Map.replace!(avaiable_phones, :p3, p3_actual)
              IO.inspect("Entro al telefono 3, la persona #{current}")
              #IO.inspect(avaiable_phones)
              callback.(callback, avaiable_phones, current + 1)

            telephone == 4 and !Process.alive?(avaiable_phones.p4) ->
              p4_actual = make_transaction(winner_call, current)
              avaiable_phones = Map.replace!(avaiable_phones, :p4, p4_actual)
              IO.inspect("Entro al telefono 4, la persona #{current}")
              #IO.inspect(avaiable_phones)
              callback.(callback, avaiable_phones, current + 1)

            true ->
              IO.inspect("Estoy esperando: #{telephone}, la persona #{current}")
              IO.inspect(self())
              #IO.inspect(avaiable_phones)
              Process.sleep(:rand.uniform(500))
              callback.(callback, avaiable_phones, current)
          end
        end
      end

      assign_call.(assign_call, avaiable_phones, current)
    end)
  end

  def make_transaction(winner_call, current) do
    spawn(fn ->
      Mnesia.transaction(fn ->
        [{Organizer, 1, actual_call}] = Mnesia.read({Organizer, 1})
        answer_call(actual_call + 1, current)
      end)
      check_winner(winner_call, current)
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

      IO.puts("#{actual_call} #{winner_call}")

      cond do
        actual_call == winner_call ->
          [{Caller, current, winner}] = Mnesia.read({Caller, current})
          IO.puts("Felicidades ganó el caller: #{current}, con el numero de llamada: #{winner}")

        actual_call > winner_call ->
          [{Caller, current, winner}] = Mnesia.read({Caller, current})
          IO.puts("Lo sentimos, ya hubo un ganador id: #{current}, tu numero de llamada fue #{winner}")

        true ->
          [{Caller, current, winner}] = Mnesia.read({Caller, current})
          IO.puts("Lo sentimos, siga intentando caller : #{current}, tu numero de llamada fue #{winner}")
      end
    end)
  end

  def reset_db do
    Mnesia.delete_table(Organizer)
    Mnesia.delete_table(Caller)
  end
end
