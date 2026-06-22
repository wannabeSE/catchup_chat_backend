defmodule CatchupChatBackendWeb.ChatChannelTest do
  use CatchupChatBackendWeb.ChannelCase, async: true

  import CatchupChatBackend.AccountsFixtures

  setup do
    user = user_fixture()
    {:ok, socket} = connect_authenticated_socket(user)
    {:ok, _reply, socket} = subscribe_and_join(socket, "chat:lobby", %{})

    %{socket: socket, user: user}
  end

  test "tracks presence after join", %{user: user} do
    assert_push "presence_state", presence
    assert Map.has_key?(presence, to_string(user.id))
  end

  test "broadcasts new_msg events", %{socket: socket, user: user} do
    push(socket, "new_msg", %{"body" => "hello"})

    assert_broadcast "new_msg", %{
      user_id: user_id,
      body: "hello",
      chat_id: "lobby",
      id: id,
      inserted_at: inserted_at
    }

    assert user_id == user.id
    assert is_binary(id)
    assert is_binary(inserted_at)
  end

  test "replies with error for invalid new_msg payload", %{socket: socket} do
    ref = push(socket, "new_msg", %{})
    assert_reply ref, :error, %{reason: "invalid payload"}
  end
end
