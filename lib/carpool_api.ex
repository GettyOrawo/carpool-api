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
  def valid_payload?(params) do

    list = insert_valid_payload(params)

    case Enum.member?(list, false) do
      true -> "invalid_payload"
      false -> "valid_payload"
    end
  end

  @doc """
  saves cars list if the payload is valid
  """

  def insert_valid_payload(cars_list) do

    Enum.map(cars_list, fn vehicle -> 

      car_map = convert_keys_to_atoms(vehicle)

      case validate_payload_format(car_map, :seats) do
        true -> 
          Cache.delete_all()
          Cache.put_cars(:cars, cars_list)
        false -> false
      end
    end)
  end

  @doc """
  Validates all payload formats for groups and cars
  """

  def validate_payload_format(map_to_validate, key) do
    required_keys = [:id, key]

    required_keys
    |> Enum.all?(&(Map.has_key?(map_to_validate, &1)) and 
      is_integer(Map.get(map_to_validate, &1)))
  end

  @doc """
  Saves groups with valid payload
  """
  def save_group_payload(param) do
    params = convert_keys_to_atoms(param)

    case validate_payload_format(params, :people) do
      true -> Cache.add_group(params.id, params)
      false -> "invalid payload"
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
    "invalid payload"
  end

  @doc """
  Tries to find a car for the incomming group
  """
  def find_car(group_id) when is_integer(group_id) do
    

    case record_exists?(:group_cache, group_id) do
      nil -> "no record"
      group -> 
        case check_cars_available_for_group(group) do
          [] -> "waiting"
          vehicle ->  Enum.min_by(vehicle, fn v -> v.seats end) 
        end
    end  
  end


  def find_car(_group_id) do
    "invalid payload"
  end

  @doc """
  Checks if there is an avaiable car for a group
  """

  def check_cars_available_for_group(group) do
    cars = get_all_cars()
    Enum.filter(cars, fn car -> car.seats >= group.people end)
  end

  @doc """
  Checks if record exists in the cache
  """

  def record_exists?(table, key) do
    Cache.get(table, key)
  end

  @doc """
  gets all cars from the cache
  """

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
