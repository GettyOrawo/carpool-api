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
  Deregisters group from cache
  """
  def delete_group(group_id) do
    GenServer.cast(CarpoolCache, {:delete_group, group_id})
  end

  @doc """
  Deregisters group from cache
  """
  def delete_all do
    GenServer.cast(CarpoolCache, {:delete_all})
  end

  @doc """
  Gets records from cache using key
  """
  def get(table, key) do
    GenServer.call(CarpoolCache, {:get, table, key})
  end

  ##server

  def handle_cast({:put_cars, key, cars}, state) do
    :ets.insert(:cars_cache, {key, cars})
    {:noreply, state}
  end

  def handle_cast({:delete_group, group_id}, state) do
    :ets.delete(:group_cache, group_id)
    {:noreply, state}
  end

  def handle_cast({:delete_all}, state) do
    :ets.delete_all_objects(:group_cache)
    :ets.delete_all_objects(:cars_cache)
    {:noreply, state}
  end

  def handle_cast({:add_group, key, group}, state) do
    :ets.insert_new(:group_cache, {key, group})
    {:noreply, state}
  end

  def handle_call({:get, table, key}, _from, state) do
    grouping = 
    case :ets.lookup(table, key) do
      [{_key, group}] -> group
      [] -> nil
    end
    {:reply, grouping, state}
  end
end