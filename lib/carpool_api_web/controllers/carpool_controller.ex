defmodule CarpoolApiWeb.CarpoolController do
  @moduledoc """
  This is the controller for every carpool request and response
  """
  use CarpoolApiWeb, :controller

  alias CarpoolApi.Cache

  def get_status(conn, _params) do
    Cache.start_link()
    conn
    |> send_resp(200, "OK")
  end
end