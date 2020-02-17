defmodule CarpoolApiWeb.CarpoolTest do
  use ExUnit.Case
  use Phoenix.ConnTest

  alias CarpoolApi.Cache

  @endpoint CarpoolApiWeb.Endpoint

  setup do
    valid_cars = 
      %{"_json" => 
        [
          %{"id" => 3, "seats" => 3},
          %{"id" => 4, "seats" => 4},
          %{"id" => 5, "seats" => 5}
        ]
      }
    invalid_cars = 
      %{"_json" => 
        [
          %{"id" => 3, "seats" => "55"},
          %{"identity" => 4, "seats" => 4},
          %{"id" => 5, "seats" => 5}
        ]
      }
    valid_group = %{"id" => 5, "people" => 5}
    invalid_group = %{"idee" => 5, "people" => "5"}
    
    Cache.start_link
    Cache.add_group(3, %{id: 3, people: 3})
    Cache.put_cars(:cars, [%{"id" => 2, "seats" => 4}, %{"id" => 5, "seats" => 10}])

    group_id = %{"id" => "3"}

    [
      valid_group: valid_group,
      invalid_group: invalid_group,
      valid_cars: valid_cars,
      invalid_cars: invalid_cars,
      group_id: group_id
    ]
  end
  

  test "starts up application successfully" do
    conn = get(build_conn(), "/status")
    assert response(conn, 200) =~ "OK"
  end

  test "saves group successfully", %{valid_group: valid_group} do
    conn = post(build_conn(), "/journey", valid_group)
    assert response(conn, 200) =~ "OK"
  end

  test "refutes invalid group payload", %{invalid_group: invalid_group} do
    conn = post(build_conn(), "/journey", invalid_group)
    assert response(conn, 400) =~ "Bad Request"
  end

  test "updates cars successfully", %{valid_cars: valid_cars} do
    conn = put(build_conn(), "/cars", valid_cars)
    assert response(conn, 200) =~ "OK"
  end

  test "refutes bad cars payload", %{invalid_cars: invalid_cars} do
    conn = put(build_conn(), "/cars", invalid_cars)
    assert response(conn, 400) =~ "Bad Request"
  end

  test "existing people can be dropped off", %{group_id: id} do
    
    assert Cache.get(:group_cache, 3) == %{id: 3, people: 3}
    conn = post(build_conn(), "/dropoff", id)
    assert response(conn, 200) =~ "OK"
    assert Cache.get(:group_cache, 3) == nil
  end

  test "dropping off non-existent group returns 404" do
    conn = post(build_conn(), "/dropoff", %{"id" => "22"})
    assert response(conn, 404) =~ "Not Found"
  end

  test "confirm valid group can be assigned a car", %{group_id: id} do
    {:ok, car}  = Jason.encode(%{"id" => 2, "seats" => 4})
    conn = post(build_conn(), "/locate", id)
    assert response(conn, 200) =~ car
  end

  test "locating non-existent group returns 404" do
    conn = post(build_conn(), "/locate", %{"id" => "277"})
    assert response(conn, 404) =~ "Not Found"
  end
end