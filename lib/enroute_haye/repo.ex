defmodule EnrouteHaye.Repo do
  use Ecto.Repo,
    otp_app: :enroute_haye,
    adapter: Ecto.Adapters.Postgres

    use Scrivener, page_size: 10
end
