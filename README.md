# CarpoolApi

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

  * use `mix test` to run tests

A few things to note:
  * I feel the use of Phoenix was an overkill, a Plug endpoint would do
  * This can use more test cases in order to test every aspect of the codebase
  * My reason for using Erlang's :ets for in memory cache storage was for efficiency as a standalone
API
  * This will be fairly performant though would be best to spawn up processes for each incomming request to handle concurrency with heavier payloads in future
  * Dialyzer would have been efficient for testing the typespecs


## Existing Endpoints
  * GET /status (starts up the service ready to accept requests and load cars)
  * PUT /cars (updates available cars ready for journey)
  * POST /journey (registers a group)
  * POST /dropoff (drops off a group whether journeyed or not)
  * POST /locate (locates a car that a group is riding in)

## With the server running you can do a number of actions
 1) You can POST to `localhost:4000/journey` with this payload
  `
  %{"id" => 33, "group" => 5}
  `
  2) Or post a group of cars to `localhost:4000/cars`
  '[
      %{"id" => 22, "seats" => 3},
      %{"id" => 555, "seats" => 15}
   ]'
  3) could as well drop off an existing group with a POST request to `localhost:4000/dropoff`
    '[
        %{"id" => 555}
     ]'

# Here are a few sample requests you could try out:

## start up the API for requests

`$ curl --location --request GET 'http://localhost:4000/status' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'idryy=2'`

## load up a few available cars

`$ curl --location --request PUT 'http://localhost:4000/cars' --header 'Content-Type: application/json' --data-raw '[{"id": 2, "seats": 8}, {"id": 3, "seats": 4}]'`

## if the cars payload is invalid expect a status 400 response

`$ curl --location --request PUT 'http://localhost:4000/cars' --header 'Content-Type: application/json' --data-raw '[{"id": 2, "suits": 8}, {"id": "unknown", "seats": "wow"}]'`

## load up a group that needs a car

`$ curl --location --request POST 'http://localhost:4000/journey' --header 'Content-Type: application/json' --data-raw '{"id": 2, "people": 3}'`

## dropoff a group whether boarded or not

`$ curl --location --request POST 'http://localhost:4000/dropoff' --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode 'id=2'`

## dropping off an invalid group returns a status 404

`$ curl --location --request POST 'http://localhost:4000/dropoff' --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode 'id=777'`

## locate a car that a group is riding in

`$ curl --location --request POST 'http://localhost:4000/journey' --header 'Content-Type: application/json' --data-raw '{"id": 22, "people": 3}'`


`$ curl --location --request POST 'http://localhost:4000/locate' --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode 'id=22'`

