defmodule EnrouteHaye.Repo do
  use Ecto.Repo,
    otp_app: :enroute_haye,
    adapter: Ecto.Adapters.Postgres
end
