defmodule CarpoolApi.Cache do
  use GenServer

  #client
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: CarpoolCache)
  end

  def init(state) do
    :ets.new(:cars_cache, [:set, :public, :named_table])
    {:ok, state}
  end

  def delete_all do
    GenServer.cast(CarpoolCache, :delete_all)
  end

  def put_cars(key, cars) do
    GenServer.cast(CarpoolCache, {:put, key, cars})
  end

  def get(key) do
    GenServer.call(CarpoolCache, {:get, key})
  end

  #server

  def handle_cast(:delete_all, state) do
    :ets.delete_all_objects(:cars_cache)
    {:noreply, state}
  end

  def handle_cast({:put, key, cars}, state) do
    :ets.insert(:cars_cache, {key, cars})
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    car = 
    case :ets.lookup(:cars_cache, key) do
      [] -> nil
      [{_key, car}] -> car
    end
    {:reply, car, state}
  end




end