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

      case Map.has_key?(params, "id") and Map.has_key?(params, "seats") do
        true -> 
          case Enum.count(params) == 2 and is_integer(params.seats) do
            true ->
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
            CarpoolApi.Cache.add_group(:group, params)
          false -> false
        end
      false -> false
    end
  end

  @doc """
  Converts map with string keys to atom keys
  """
  def convert_keys_to_atoms(params) do 
    for {key, val} <- params, into: %{}, do: {String.to_atom(key), val}
  end

end
