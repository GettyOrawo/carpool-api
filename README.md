# CarpoolApi

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

  * use `mix test` to run tests

A few things to note:
  * used Phoenix but turns out it was an overkill, would've been better to just do a simple mix project
  * More test cases are in order to test every aspect of the codebase more so the context functions(unit tests)
  * Used Erlang's :ets for in memory cache storage, this is efficient for the API to be standalone
  * Would be best to spawn up a process for each incomming request to handle concurrency with heavier payloads in future


## Existing Endpoints
  * GET /status (starts up the service ready to accept requests and load cars)
  * PUT /cars (updates available cars ready for journey)
  * POST /journey (registers a group)
  * POST /dropoff (drops off a group whether journeyed or not)
  * POST /locate (locates a car that a group is riding in)

  # Here are a few requests you could play around with

# start up the API for requests

curl --location --request GET 'http://localhost:4000/status' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'idryy=2'

# load up a few available cars

curl --location --request PUT 'http://localhost:4000/cars' \
--header 'Content-Type: application/json' \
--data-raw '[{"id": 2, "seats": 8}, {"id": 3, "seats": 4}]'

#if the cars payload is invalid expect a status 400 response

curl --location --request PUT 'http://localhost:4000/cars' \
--header 'Content-Type: application/json' \
--data-raw '[{"id": 2, "suits": 8}, {"id": "unknown", "seats": "wow"}]'

# load up a group that needs a car

curl --location --request POST 'http://localhost:4000/journey' \
--header 'Content-Type: application/json' \
--data-raw '{"id": 2, "people": 3}'

#dropoff a group whether boarded or not

curl --location --request POST 'http://localhost:4000/dropoff' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'id=2'

# dropping off an invalid group returns a status 404

curl --location --request POST 'http://localhost:4000/dropoff' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'id=777'

# locate a car that a group is riding in

curl --location --request POST 'http://localhost:4000/journey' \
--header 'Content-Type: application/json' \
--data-raw '{"id": 22, "people": 3}'


curl --location --request POST 'http://localhost:4000/locate' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'id=22'