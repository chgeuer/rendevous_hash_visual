defmodule RendevousHashVisual.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RendevousHashVisualWeb.Telemetry,
      {DNSCluster,
       query: Application.get_env(:rendevous_hash_visual, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RendevousHashVisual.PubSub},
      # Start a worker by calling: RendevousHashVisual.Worker.start_link(arg)
      # {RendevousHashVisual.Worker, arg},
      # Start to serve requests, typically the last entry
      RendevousHashVisualWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RendevousHashVisual.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RendevousHashVisualWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
