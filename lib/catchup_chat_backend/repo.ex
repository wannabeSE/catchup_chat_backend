defmodule CatchupChatBackend.Repo do
  use Ecto.Repo,
    otp_app: :catchup_chat_backend,
    adapter: Ecto.Adapters.Postgres
end
