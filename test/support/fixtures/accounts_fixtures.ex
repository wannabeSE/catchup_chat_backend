defmodule CatchupChatBackend.AccountsFixtures do
  @moduledoc """
  Test helpers for creating account entities.
  """

  alias CatchupChatBackend.Accounts

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def valid_user_password, do: "hello world!"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        password: valid_user_password()
      })
      |> Accounts.register_user()

    user
  end

  def user_session_token(user) do
    Accounts.generate_user_session_token(user)
  end

  def authenticated_conn(conn, user) do
    token = user_session_token(user)
    encoded = Base.url_encode64(token, padding: false)

    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{encoded}")
  end
end
