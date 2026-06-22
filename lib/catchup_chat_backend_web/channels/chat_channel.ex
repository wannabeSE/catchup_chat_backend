defmodule CatchupChatBackendWeb.ChatChannel do
  @moduledoc """
  Real-time chat channel. Topics follow the pattern `chat:<chat_id>`.
  """
  use CatchupChatBackendWeb, :channel

  alias CatchupChatBackendWeb.Presence

  @impl true
  def join("chat:" <> chat_id, _payload, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :chat_id, chat_id)}
  end

  @impl true
  def handle_info(:after_join, socket) do
    user = socket.assigns.current_user

    {:ok, _} =
      Presence.track(socket, user.id, %{
        id: user.id,
        email: user.email,
        name: user.name
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_msg", %{"body" => body}, socket) when is_binary(body) and body != "" do
    user = socket.assigns.current_user

    broadcast!(socket, "new_msg", %{
      id: Ecto.UUID.generate(),
      chat_id: socket.assigns.chat_id,
      user_id: user.id,
      body: body,
      inserted_at: DateTime.to_iso8601(DateTime.utc_now(:second))
    })

    {:noreply, socket}
  end

  def handle_in("new_msg", _payload, socket) do
    {:reply, {:error, %{reason: "invalid payload"}}, socket}
  end
end
