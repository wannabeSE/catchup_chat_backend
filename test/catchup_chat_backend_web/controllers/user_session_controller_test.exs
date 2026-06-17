defmodule CatchupChatBackendWeb.UserSessionControllerTest do
  use CatchupChatBackendWeb.ConnCase, async: true

  import CatchupChatBackend.AccountsFixtures

  describe "POST /api/users/register" do
    test "creates a user and returns a token", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, ~p"/api/users/register", %{
          user: %{email: email, password: valid_user_password()}
        })

      assert %{"data" => %{"id" => _id, "email" => ^email}, "token" => token} =
               json_response(conn, 201)

      assert is_binary(token)
    end

    test "returns errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/api/users/register", %{
          user: %{email: "bad", password: "short"}
        })

      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["email"]
      assert errors["password"]
    end

    test "accepts flat json params with profile fields", %{conn: conn} do
      conn =
        post(conn, ~p"/api/users/register", %{
          email: unique_user_email(),
          password: valid_user_password(),
          name: "userT",
          last_coordinates: %{}
        })

      assert %{"data" => %{"name" => "userT", "last_coordinates" => %{}}, "token" => _} =
               json_response(conn, 201)
    end

    test "defaults last_coordinates to empty map when omitted", %{conn: conn} do
      conn =
        post(conn, ~p"/api/users/register", %{
          email: unique_user_email(),
          password: valid_user_password(),
          name: "userT"
        })

      assert %{"data" => %{"last_coordinates" => %{}}} = json_response(conn, 201)
    end

    test "accepts last_coordinate as an alias for last_coordinates", %{conn: conn} do
      conn =
        post(conn, ~p"/api/users/register", %{
          email: unique_user_email(),
          password: valid_user_password(),
          name: "userT",
          last_coordinate: %{"lat" => 1.0, "lng" => 2.0}
        })

      assert %{"data" => %{"last_coordinates" => %{"lat" => 1.0, "lng" => 2.0}}} =
               json_response(conn, 201)
    end

    test "returns errors for duplicate email", %{conn: conn} do
      email = unique_user_email()
      user_fixture(%{email: email})

      conn =
        post(conn, ~p"/api/users/register", %{
          email: email,
          password: valid_user_password(),
          name: "userT",
          last_coordinates: %{}
        })

      assert %{"errors" => %{"email" => [_ | _]}} = json_response(conn, 422)
    end
  end

  describe "POST /api/users/log-in" do
    test "returns a token for valid credentials", %{conn: conn} do
      user = user_fixture()

      conn =
        post(conn, ~p"/api/users/log-in", %{
          user: %{email: user.email, password: valid_user_password()}
        })

      assert %{"data" => %{"email" => email}, "token" => token} = json_response(conn, 200)
      assert email == user.email
      assert is_binary(token)
    end

    test "returns unauthorized for invalid credentials", %{conn: conn} do
      user = user_fixture()

      conn =
        post(conn, ~p"/api/users/log-in", %{
          user: %{email: user.email, password: "wrong password!"}
        })

      assert %{"errors" => %{"detail" => "Invalid email or password"}} =
               json_response(conn, 401)
    end
  end

  describe "GET /api/users/me" do
    test "returns the current user", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> authenticated_conn(user)
        |> get(~p"/api/users/me")

      assert %{"data" => %{"id" => id, "email" => email}} = json_response(conn, 200)
      assert id == user.id
      assert email == user.email
    end

    test "returns unauthorized without a token", %{conn: conn} do
      conn = get(conn, ~p"/api/users/me")
      assert json_response(conn, 401)
    end
  end

  describe "DELETE /api/users/log-out" do
    test "revokes the session token", %{conn: conn} do
      user = user_fixture()
      conn = authenticated_conn(conn, user)

      conn = delete(conn, ~p"/api/users/log-out")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/users/me")
      assert json_response(conn, 401)
    end
  end
end
