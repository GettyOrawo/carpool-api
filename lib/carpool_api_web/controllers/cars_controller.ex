defmodule CarpoolApiWeb.CarsController do
  use CarpoolApiWeb, :controller


  @moduledoc """
  Welcome to Cabify, would you fancy a carpool?
  The following actions are available;
  1. Startup by sending a GET request to /status
  2. Update existing vehicles by sending a POST request with a JSON payload to /cars
  5. Locate the car a group is riding in using a form input of id through POST /locate
  """

  @doc """
  Starts Caching server and responds to /status endpoint with a 200 OK
  """
  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(conn, _params) do
    CarpoolApi.Cache.start_link()
    conn
    |> send_resp(200, "OK")
  end

  @doc """
  Add list of cars to the cache
  """
  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"_json" => params}) do
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
  Locates the car by which the given group id is riding with
  """

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, params) do
    case CarpoolApi.find_car(params) do
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