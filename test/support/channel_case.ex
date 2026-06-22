defmodule CatchupChatBackendWeb.ChannelCase do
  @moduledoc """
  Test case for channel tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      import CatchupChatBackend.AccountsFixtures

      alias CatchupChatBackendWeb.UserSocket

      @endpoint CatchupChatBackendWeb.Endpoint

      def connect_authenticated_socket(user) do
        token = user_session_token(user)
        encoded = Base.url_encode64(token, padding: false)
        connect(UserSocket, %{"token" => encoded})
      end
    end
  end

  setup tags do
    CatchupChatBackend.DataCase.setup_sandbox(tags)
    :ok
  end
end
