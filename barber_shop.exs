defmodule Shop do
  @name :barber_shop
  @num_chairs 3

  # Public API

  # spawn shop loop, register shop, pass shop to Barber
  def open do
    shop = spawn(__MODULE__, :loop, [initial_state])
    :global.register_name(@name, shop)
    Barber.register(shop)
  end

  # add array of customers to shop
  def add(customers) when is_list(customers) do
    customers |> Enum.map(&add/1)
  end

  # add one customer to shop
  def add(customer) do
    send(shop, {:add, customer})
  end

  # check status of shop
  def status? do
    send(shop, {:shop_status})
  end

  # check status of barber
  def barber? do
    send(shop, {:barber_status})
  end

  # Private API

  defp initial_state do
    %{barber: nil, in_chair: nil, waiting: []}
  end

  def loop(state) do
    receive do
      {:add, customer}           -> add(customer, state)
      {:barber_done}             -> barber_done(state)
      {:shop_status}             -> shop_status(state)
      {:barber_status}           -> barber_status(state)
      {:register_barber, barber} -> register_barber(barber, state)
    end
    loop(state)
  end

  # loop actions

  defp add(customer, state = %{in_chair: in_chair}) when is_nil(in_chair) do
    IO.puts("barber chair is empty, #{customer} is waking up the barber")
    send(state.barber, {:cut_hair, customer})
    loop(%{state | in_chair: customer })
  end

  defp add(customer, state = %{waiting: waiting}) when length(waiting) == @num_chairs do
    IO.puts("shop is full, #{customer} is leaving")
    loop(state)
  end

  defp add(customer, state) do
    IO.puts("#{customer} is sitting down")
    loop(%{state | waiting: state.waiting ++ [customer]})
  end

  defp barber_done(state) do
    IO.puts("barber is finished cutting hair for #{state.in_chair}")
    handle_next_customer(state)
  end

  defp handle_next_customer(state = %{waiting: [next|remaining]}) do
    IO.puts("#{next} is next in line")
    send(state.barber, {:cut_hair, next})
    loop(%{ state | in_chair: next, waiting: remaining})
  end

  defp handle_next_customer(state = %{waiting: []}) do
    IO.puts("no one else is waiting")
    loop(%{ state | in_chair: nil})
  end

  defp shop_status(state) do
    IO.puts("in chair: #{inspect(state.in_chair)}")
    IO.puts("waiting: #{inspect(state.waiting)}")
  end

  defp barber_status(%{in_chair: nil}) do
    IO.puts("barber fell asleep")
  end

  defp barber_status(%{in_chair: customer}) do
    IO.puts("barber is currently cutting hair for #{customer}")
  end

  defp register_barber(barber, state) do
    IO.puts("registering barber: #{inspect(barber)}")
    loop(%{state | barber: barber})
  end

  # lookup shop pid
  defp shop do
    :global.whereis_name(@name)
  end
end

defmodule Barber do
  @time_per_cut 5_000
  @time_until_bored 15_000

  # spawn barber loop, register barber with shop
  def register(shop) do
    barber = spawn(__MODULE__, :loop, [shop])
    send(shop, {:register_barber, barber})
  end

  def loop(shop) do
    receive do
      {:cut_hair, customer}   -> cut_hair(customer, shop)
      after @time_until_bored -> express_boredom
    end
    loop(shop)
  end

  defp cut_hair(customer, shop) do
    IO.puts("cutting hair for #{customer}")
    :timer.sleep(@time_per_cut)
    send(shop, {:barber_done})
  end

  defp express_boredom do
    IO.puts("yawn. not much to do around here...")
  end
end
