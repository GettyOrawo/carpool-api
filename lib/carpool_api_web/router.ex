defmodule CarpoolApiWeb.Router do
  use CarpoolApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
  end

  scope "/api", CarpoolApiWeb do
    pipe_through :api
  end

  scope "/", CarpoolApiWeb do
    pipe_through :browser

    get "/status", CarpoolController, :get_status
    put "/cars", CarpoolController, :put_cars
  end
end
