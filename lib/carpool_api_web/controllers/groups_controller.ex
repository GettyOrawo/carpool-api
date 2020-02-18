defmodule CarpoolApiWeb.GroupsController do
  use CarpoolApiWeb, :controller

  @moduledoc """
  Welcome to Cabify, would you fancy a carpool?
  The following actions are available here;
  1. Add a group through a POST request to /journey with a JSON payload
  2. Dropoff a group, POST /dropoff with a form input of id
  """


  @doc """
  registers group of people to start journey
  """
  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
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

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, params) do
    case CarpoolApi.validate_group_id_and_deregister(params) do
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
end