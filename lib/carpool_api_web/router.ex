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

    get "/status", CarsController, :new
    put "/cars", CarsController, :create
    post "/journey", GroupsController, :create
    post "/dropoff", GroupsController, :delete
    post "/locate", CarsController, :show
  end
end
