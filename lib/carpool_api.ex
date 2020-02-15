defmodule CarpoolApi do
  @moduledoc """
  CarpoolApi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

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

  def filter_by_keys_and_length(params) do

    Enum.map(params, fn param -> 
      params = convert_keys_to_atoms(param)

      case Map.has_key?(params, :id) and Map.has_key?(params, :seats) do
        true -> 
          case Enum.count(params) == 2 and is_integer(params.seats) do
            true ->
              CarpoolApi.Cache.delete_all()
              CarpoolApi.Cache.put_cars(:cars, params)
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
            CarpoolApi.Cache.add_group(params.id, params)
          false -> false
        end
      false -> false
    end
  end

  @doc """
  Validates incomming id formats before deregistering valid group
  """
  def validate_group_id_and_deregister(group_id), when is_integer(group_id) do
    case record_exists?(:group_cache, group_id) do
      nil -> "no record"
      _group -> 
        CarpoolApi.Cache.delete_group(group_id)
    end
  end

    def validate_group_id_and_deregister(_group_id) do
      false
    end
  end

  @doc """
  Tries to find a car for the incomming group
  """
  def find_car(group, cars), when record_exists?(table, key) and is_integer(group.id) do
    case Enum.filter(cars, fn car -> car.seats >= group.people) do
      [] -> "waiting"
      vehicle ->  Enum.min_by(vehicle, fn v -> v.seats end)
    end
  end

  def find_car(group, cars), when is_integer(group.id) do
    "no record"
  end

  def find_car(group, cars) do
    "invalid payload"
  end

  @doc """
  Checks if record exists in the cache
  """

  def record_exists?(table, key) do
    CarpoolApi.Cache.get(table, key)
  end

  @doc """
  Converts map with string keys to atom keys
  """
  def convert_keys_to_atoms(params) do 
    for {key, val} <- params, into: %{}, do: {String.to_atom(key), val}
  end

end
