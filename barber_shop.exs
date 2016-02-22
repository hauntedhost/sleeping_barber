defmodule Shop do
  use GenServer
  @name :barber_shop
  @num_chairs 3
  @time_per_cut 5_000

  def open do
    shop || spawn_shop
  end

  # add array of customers to shop
  def add(customers) when is_list(customers) do
    customers |> Enum.map(&add/1)
  end

  # add one customer to shop
  def add(customer) do
    GenServer.call(shop, {:add, customer})
  end

  # check status of shop
  def status do
    GenServer.call(shop, {:status})
  end

  # GenServer

  def handle_call({:add, customer}, _from, state) do
    case state do
      %{in_chair: in_chair} when is_nil(in_chair) ->
        IO.puts("barber chair is empty, #{customer} is waking up the barber")
        GenServer.cast(shop, {:cut_hair, customer})
        {:reply, :ok, %{state | in_chair: customer}}
      %{waiting: waiting} when length(waiting) == @num_chairs ->
        IO.puts("shop is full, #{customer} is leaving")
        {:reply, :ok, state}
      _ ->
        IO.puts("#{customer} is sitting down")
        {:reply, :ok, %{state | waiting: state.waiting ++ [customer]}}
    end
  end

  def handle_call({:barber_done}, _from, state) do
    case state do
      %{waiting: [next|remaining]} ->
        IO.puts("#{next} is next in line")
        GenServer.cast(shop, {:cut_hair, next})
        {:reply, :ok, %{ state | in_chair: next, waiting: remaining}}
      _ ->
        IO.puts("no one else is waiting")
        {:reply, :ok, %{ state | in_chair: nil}}
    end
  end

  def handle_call({:status}, _from, state) do
    IO.puts("in chair: #{inspect(state.in_chair)}")
    IO.puts("waiting: #{inspect(state.waiting)}")
    {:reply, :ok, state}
  end

  def handle_cast({:cut_hair, customer}, state) do
    IO.puts("barber is cutting hair for #{customer}")
    Task.async(fn ->
      :timer.sleep(@time_per_cut)
      IO.puts("barber is done cutting hair for #{customer}")
      GenServer.call(shop, {:barber_done})
    end)
    {:noreply, state}
  end

  # private API

  # spawn shop, register shop as a global
  defp spawn_shop do
    {:ok, shop} = GenServer.start_link(__MODULE__, initial_state)
    :global.register_name(@name, shop)
    shop
  end

  defp initial_state do
    %{in_chair: nil, waiting: []}
  end

  # lookup shop pid
  defp shop do
    case :global.whereis_name(@name) do
      :undefined -> nil
      shop_pid   -> shop_pid
    end
  end
end
