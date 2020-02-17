defmodule CarpoolApiWeb.CarpoolController do
  @moduledoc """
  This is the controller for every carpool request and response
  """
  use CarpoolApiWeb, :controller

  alias CarpoolApi.Cache

  @doc """
  Starts Caching server and responds to /status endpoint with a 200 OK
  """
  def get_status(conn, _params) do
    Cache.start_link()
    conn
    |> send_resp(200, "OK")
  end

  @doc """
  Add list of cars to the cache
  """
  
  def put_cars(conn, %{"_json" => params}) do
    case CarpoolApi.valid_payload?(params) do
      "valid_payload" -> 
        conn
        |> send_resp(200, "OK")
      "invalid_payload" ->
        conn
        |> send_resp(400, "Bad Request")
    end
  end

  @doc """
  registers group of people to start journey
  """
  
  def put_groups(conn, params) do
    case CarpoolApi.save_group_payload(params) do
      :ok ->
        conn
        |> send_resp(200, "OK")
        
      "invalid payload" ->
        conn
        |> send_resp(400, "Bad Request")
    end
  end

  @doc """
  deregisters group of people from journey
  """

  def dropoff(conn, %{"id" => group_id}) do
    case CarpoolApi.validate_group_id_and_deregister(String.to_integer(group_id)) do
      :ok ->
        conn
        |> send_resp(200, "OK")
      "no record" ->
        conn
        |> send_resp(404, "Not Found")
      "invalid payload" ->
        conn
        |> send_resp(400, "Bad Request")
    end
  end

  @doc """
  Locates the car by which the given group id is riding with
  """
  def locate(conn, %{"id" => group_id}) do
    case CarpoolApi.find_car(String.to_integer(group_id)) do
      "waiting" ->
        conn
        |> send_resp(204, "No Content")
      "no record" ->
        conn
        |> send_resp(404, "Not Found")
      "invalid payload" ->
        conn
        |> send_resp(400, "Bad Request")
      boarded_car ->
        {:ok, car} = Jason.encode boarded_car
        conn
        |> resp(200, car)
    end
  end
end