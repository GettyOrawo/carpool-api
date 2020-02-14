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
    case CarpoolApi.validate_cars_payload_format(params) do
      true -> 
        conn
        |> send_resp(200, "OK")
      false ->
        conn
        |> send_resp(400, "Bad Request")
    end
  end

  @doc """
  add group of people to the cache
  """
  
  def put_groups(conn, params) do
    IO.inspect CarpoolApi.validate_group_payload_format(params)
    case CarpoolApi.validate_group_payload_format(params) do
      :ok ->
        conn
        |> send_resp(200, "OK")
      false ->
        conn
        |> send_resp(400, "Bad Request")
    end
  end
end