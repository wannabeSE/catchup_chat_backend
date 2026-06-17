defmodule CatchupChatBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CatchupChatBackendWeb.Telemetry,
      CatchupChatBackend.Repo,
      {DNSCluster,
       query: Application.get_env(:catchup_chat_backend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CatchupChatBackend.PubSub},
      # Start a worker by calling: CatchupChatBackend.Worker.start_link(arg)
      # {CatchupChatBackend.Worker, arg},
      # Start to serve requests, typically the last entry
      CatchupChatBackendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CatchupChatBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CatchupChatBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
