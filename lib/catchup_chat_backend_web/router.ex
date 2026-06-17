defmodule CatchupChatBackendWeb.Router do
  use CatchupChatBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug CatchupChatBackendWeb.Plugs.AuthenticateUser
  end

  scope "/api", CatchupChatBackendWeb do
    pipe_through :api

    post "/users/register", UserSessionController, :register
    post "/users/log-in", UserSessionController, :log_in
  end

  scope "/api", CatchupChatBackendWeb do
    pipe_through [:api, :api_auth]

    get "/users/me", UserSessionController, :me
    delete "/users/log-out", UserSessionController, :log_out
  end
end
