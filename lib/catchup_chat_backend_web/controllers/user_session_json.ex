defmodule CatchupChatBackendWeb.UserSessionJSON do
  alias CatchupChatBackend.Accounts.User

  def show(%{user: user}) do
    %{data: user(user)}
  end

  def session(%{user: user, token: token}) do
    %{
      data: user(user),
      token: Base.url_encode64(token, padding: false)
    }
  end

  defp user(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      name: user.name,
      last_coordinates: user.last_coordinates || %{},
      is_admin: user.is_admin
    }
  end
end
