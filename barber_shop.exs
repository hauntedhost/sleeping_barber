defmodule Shop do
  @name :barber_shop
  @num_chairs 3

  # Public API

  # spawn #loop, pass pid to Barber
  def open do
    shop_pid = spawn(__MODULE__, :loop, [])
    :global.register_name(@name, shop_pid)
    Barber.register(shop_pid)
  end

  # add array of customers to shop
  def add(customers) when is_list(customers) do
    customers |> Enum.map(&add/1)
  end

  # add one customer to shop
  def add(customer) do
    send(self_pid, {:add, customer})
  end

  # check status of shop
  def status? do
    send(self_pid, {:shop_status})
  end

  # check status of barber
  def barber? do
    send(self_pid, {:barber_status})
  end

  # Private API

  def loop(barber_pid \\ nil, in_chair \\ nil, waiting \\ []) do
    receive do
      {:add, customer}               -> add(customer, barber_pid, in_chair, waiting)
      {:barber_done}                 -> barber_done(barber_pid, in_chair, waiting)
      {:shop_status}                 -> shop_status(in_chair, waiting)
      {:barber_status}               -> barber_status(in_chair)
      {:register_barber, barber_pid} -> register_barber(barber_pid)
    end
    loop(barber_pid, in_chair, waiting)
  end

  # receive actions

  defp add(customer, barber_pid, in_chair, waiting) do
    cond do
      chair_empty?(in_chair) ->
        send(barber_pid, {:cut, customer})
        loop(barber_pid, customer, waiting)
      shop_full?(waiting) ->
        IO.puts("shop is full, #{customer} is leaving ...")
        loop(barber_pid, in_chair, waiting)
      true ->
        IO.puts("#{customer} is sitting down")
        loop(barber_pid, in_chair, waiting ++ [customer])
    end
  end

  defp barber_done(barber_pid, in_chair, waiting) do
    IO.puts("barber is finished cutting hair for #{in_chair}")
    case waiting do
      [next|remaining] ->
        send(barber_pid, {:cut, next})
        loop(barber_pid, next, remaining)
      [] ->
        loop(barber_pid, nil, [])
    end
  end

  defp shop_status(in_chair, waiting) do
    IO.puts("in chair: #{inspect(in_chair)}")
    IO.puts("waiting: #{inspect(waiting)}")
  end

  defp barber_status(nil) do
    IO.puts("barber fell asleep")
  end

  defp barber_status(in_chair) do
    IO.puts("barber is currently cutting hair for #{in_chair}")
  end

  defp register_barber(barber_pid) do
    IO.puts("registering barber: #{inspect(barber_pid)}")
    loop(barber_pid)
  end

  # boolean helpers
  defp chair_empty?(in_chair) do
    is_nil(in_chair)
  end

  defp shop_full?(waiting) do
    Enum.count(waiting) >= @num_chairs
  end

  # lookup self pid
  defp self_pid do
    :global.whereis_name(@name)
  end
end

defmodule Barber do
  @time_per_cut 5_000
  @time_until_bored 15_000

  # spawn #loop, register pid with shop
  def register(shop_pid) do
    barber_pid = spawn(__MODULE__, :loop, [shop_pid])
    send(shop_pid, {:register_barber, barber_pid})
  end

  def loop(shop_pid) do
    receive do
      {:cut, customer} ->
        IO.puts("cutting hair for #{customer}")
        :timer.sleep(@time_per_cut)
        send(shop_pid, {:barber_done})
      after @time_until_bored ->
        IO.puts("yawn. not much to do around here...")
    end
    loop(shop_pid)
  end
end
