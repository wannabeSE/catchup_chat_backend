defmodule CatchupChatBackendWeb.UserSocketTest do
  use CatchupChatBackendWeb.ChannelCase, async: true

  import CatchupChatBackend.AccountsFixtures

  describe "connect/3" do
    test "connects with a valid session token" do
      user = user_fixture()

      assert {:ok, socket} = connect_authenticated_socket(user)
      assert socket.assigns.current_user.id == user.id
    end

    test "rejects an invalid token" do
      assert :error = connect(UserSocket, %{"token" => "invalid"})
    end

    test "rejects a missing token" do
      assert :error = connect(UserSocket, %{})
    end
  end
end
