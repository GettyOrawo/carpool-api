defmodule CarpoolApi do
  @moduledoc """
  CarpoolApi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias CarpoolApi.Cache

  @doc """
  Validates all payload formats for cars before save
  """
  def validate_cars_payload_format(params) do

    list = filter_by_keys_and_length(params)

    case Enum.member?(list, false) do
      true -> false
      false -> true
    end
  end

  @doc """
  Filters the incoming params by availability of the "id" and "seats" keys 
  and that no other keys are passed in
  """

  def filter_by_keys_and_length(cars_list) do

    Enum.map(cars_list, fn vehicle -> 
      car_map = convert_keys_to_atoms(vehicle)

      case Map.has_key?(car_map, :id) and Map.has_key?(car_map, :seats) do
        true -> 
          case Enum.count(car_map) == 2 and is_integer(car_map.seats) do
            true ->
              Cache.delete_all()
              Cache.put_cars(:cars, cars_list)
            false -> false
          end
        false -> false
      end
    end)
  end

  @doc """
  Validates all payload formats for groups before save
  """
  def validate_group_payload_format(param) do
    params = convert_keys_to_atoms(param)

    case Map.has_key?(params, :id) and Map.has_key?(params, :people) do
      true -> 
        case Enum.count(params) == 2 and is_integer(params.people) do
          true -> 
            Cache.add_group(params.id, params)
          false -> false
        end
      false -> false
    end
  end

  @doc """
  Validates incomming id formats before deregistering valid group
  """
  def validate_group_id_and_deregister(group_id) when is_integer(group_id) do
    case record_exists?(:group_cache, group_id) do
      nil -> "no record"
      _group -> 
        Cache.delete_group(group_id)
    end
  end

  def validate_group_id_and_deregister(_group_id) do
    false
  end

  @doc """
  Tries to find a car for the incomming group
  """
  def find_car(group_id) when is_integer(group_id) do
    cars = get_all_cars()


    case record_exists?(:group_cache, group_id) do
      nil -> "no record"
      group -> 
        case Enum.filter(cars, fn car -> car.seats >= group.people end) do
          [] -> "waiting"
          vehicle ->  Enum.min_by(vehicle, fn v -> v.seats end) 
        end
    end  
  end

  def find_car(group_id) do
    "invalid payload"
  end

  @doc """
  Checks if record exists in the cache
  """

  def record_exists?(table, key) do
    Cache.get(table, key)
  end

  def get_all_cars do
    Cache.get(:cars_cache, :cars)
    |> Enum.map(fn car -> convert_keys_to_atoms(car) end)
  end
  @doc """
  Converts map with string keys to atom keys
  """
  def convert_keys_to_atoms(params) do 
    for {key, val} <- params, into: %{}, do: {String.to_atom(key), val}
  end

end
