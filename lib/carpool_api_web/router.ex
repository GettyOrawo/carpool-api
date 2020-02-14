defmodule CarpoolApiWeb.Router do
  use CarpoolApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
  end

  scope "/", CarpoolApiWeb do
    pipe_through :api

    get "/status", CarpoolController, :get_status
    put "/cars", CarpoolController, :put_cars
    post "/journey", CarpoolController, :put_groups
  end
end
