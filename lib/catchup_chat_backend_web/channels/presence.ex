defmodule CatchupChatBackendWeb.Presence do
  @moduledoc """
  Tracks which users are connected to each chat topic.
  """
  use Phoenix.Presence,
    otp_app: :catchup_chat_backend,
    pubsub_server: CatchupChatBackend.PubSub
end
