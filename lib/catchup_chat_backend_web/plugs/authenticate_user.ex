defmodule CatchupChatBackendWeb.Plugs.AuthenticateUser do
  @moduledoc """
  Authenticates API requests using a Bearer token.
  """
  import Plug.Conn

  alias CatchupChatBackend.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> encoded_token] <- get_req_header(conn, "authorization"),
         {:ok, token} <- Base.url_decode64(encoded_token, padding: false),
         {user, _inserted_at} <- Accounts.get_user_by_session_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.put_view(json: CatchupChatBackendWeb.ErrorJSON)
        |> Phoenix.Controller.render(:"401")
        |> halt()
    end
  end
end
