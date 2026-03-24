defmodule EnrouteHaye.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EnrouteHayeWeb.Telemetry,
      EnrouteHaye.Repo,
      {DNSCluster, query: Application.get_env(:enroute_haye, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: EnrouteHaye.PubSub},
      EnrouteHaye.PDFStore,
      ChromicPDF,
      EnrouteHayeWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: EnrouteHaye.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    EnrouteHayeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
