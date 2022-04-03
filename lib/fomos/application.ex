defmodule Fomos.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Fomos.Repo,
      # Start the Telemetry supervisor
      FomosWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Fomos.PubSub},
      # Start the Endpoint (http/https)
      FomosWeb.Endpoint
      # Start a worker by calling: Fomos.Worker.start_link(arg)
      # {Fomos.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fomos.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FomosWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
