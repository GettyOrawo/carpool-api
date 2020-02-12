defmodule CarpoolApiWeb.Router do
  use CarpoolApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CarpoolApiWeb do
    pipe_through :api
  end
end
