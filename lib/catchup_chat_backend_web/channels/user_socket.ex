defmodule CatchupChatBackendWeb.UserSocket do
  @moduledoc """
  WebSocket entry point. Clients must pass a session token in connect params:

      %{"token" => "<base64 token from login/register>"}
  """
  use Phoenix.Socket

  channel "chat:*", CatchupChatBackendWeb.ChatChannel

  @impl true
  def connect(%{"token" => encoded_token}, socket, _connect_info) do
    case CatchupChatBackend.Accounts.get_user_by_encoded_session_token(encoded_token) do
      {:ok, user} -> {:ok, assign(socket, :current_user, user)}
      :error -> :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.current_user.id}"
end
