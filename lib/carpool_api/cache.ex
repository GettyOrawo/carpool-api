defmodule CarpoolApi.Cache do
  @moduledoc """
  Creates a Genserver forin memoiry Cache using Erlang's :ets
  """
  use GenServer

  #client

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: CarpoolCache)
  end

  def init(state) do
    :ets.new(:cars_cache, [:set, :public, :named_table])
    :ets.new(:group_cache, [:set, :public, :named_table])
    {:ok, state}
  end


  @doc """
  Inserts cars records into cache or updates for duplicate keys
  """
  def put_cars(key, cars) do
    GenServer.cast(CarpoolCache, {:put_cars, key, cars})
  end

   @doc """
  Inserts group records into cache
  """
  def add_group(key, group) do
    GenServer.cast(CarpoolCache, {:add_group, key, group})
  end

  @doc """
  Gets records from cache using key
  """
  def get(key) do
    GenServer.call(CarpoolCache, {:get, key})
  end

  ##server

  def handle_cast({:put_cars, key, cars}, state) do
    :ets.insert(:cars_cache, {key, cars})
    {:noreply, state}
  end

  def handle_cast({:add_group, key, group}, state) do
    :ets.insert_new(:group_cache, {key, group})
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