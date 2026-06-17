defmodule CatchupChatBackendWeb.UserSessionController do
  use CatchupChatBackendWeb, :controller

  alias CatchupChatBackend.Accounts

  action_fallback CatchupChatBackendWeb.FallbackController

  def register(conn, params) do
    user_params = normalize_user_params(params)

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        token = Accounts.generate_user_session_token(user)

        conn
        |> put_status(:created)
        |> render(:session, user: user, token: token)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CatchupChatBackendWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  defp normalize_user_params(params) do
    params = Map.get(params, "user", params)

    case params do
      %{"last_coordinate" => coordinates} = user_params ->
        user_params
        |> Map.put("last_coordinates", coordinates)
        |> Map.delete("last_coordinate")

      user_params ->
        user_params
    end
  end

  def log_in(conn, %{"user" => %{"email" => email, "password" => password}}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = Accounts.generate_user_session_token(user)

      render(conn, :session, user: user, token: token)
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(json: CatchupChatBackendWeb.ErrorJSON)
      |> render(:"401", message: "Invalid email or password")
    end
  end

  def log_in(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: CatchupChatBackendWeb.ErrorJSON)
    |> render(:"400", message: "Expected user with email and password")
  end

  def me(conn, _params) do
    render(conn, :show, user: conn.assigns.current_user)
  end

  def log_out(conn, _params) do
    with ["Bearer " <> encoded_token] <- get_req_header(conn, "authorization"),
         {:ok, token} <- Base.url_decode64(encoded_token, padding: false) do
      Accounts.delete_user_session_token(token)
    end

    send_resp(conn, :no_content, "")
  end
end
