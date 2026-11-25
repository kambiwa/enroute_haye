defmodule EnrouteHaye.Trips.Admin do
  @moduledoc """
  Admin-only trip queries. These bypass the visitor/guest ownership scope,
  so only call them from admin-protected routes.
  """

  import Ecto.Query, warn: false

  alias EnrouteHaye.Repo
  alias EnrouteHaye.Trips.Trip

  # Must cover everything BudgetCalculator.calculate/1 reads. Keep this in sync
  # with the preload list used by EnrouteHaye.Trips.get_trip/3.
  @preloads [
    :selected_event,
    :expenses,
    :transport_segments,
    trip_stops: :site,
    accommodation_selections: :accommodation,
    food_selections: :food,
    audio_selections: :audio
  ]

  def list_trips(pagination_params, filters) do
    Trip
    |> search(filters[:search_filter])
    |> timing(filters[:timing_filter])
    |> order_by([t], desc: t.updated_at)
    # Keep this the same as the paginate call in CxtSite.list_sites/2 so the
    # PaginationComponent gets the same shape back.
    |> Repo.paginate(pagination_params)
  end

  def get_trip!(id), do: Trip |> Repo.get!(id) |> Repo.preload(@preloads)

  def change_trip(%Trip{} = trip, attrs \\ %{}), do: Trip.changeset(trip, attrs)

  def update_trip(%Trip{} = trip, attrs) do
    trip
    |> Trip.changeset(attrs)
    |> Repo.update()
  end

  defp search(query, search) when search in [nil, ""], do: query

  defp search(query, search) do
    term = "%#{String.trim(search)}%"

    where(
      query,
      [t],
      ilike(t.title, ^term) or ilike(t.traveller_name, ^term) or
        ilike(t.starting_district, ^term) or ilike(t.destination_district, ^term)
    )
  end

  defp timing(query, "upcoming"),
    do: where(query, [t], t.start_date > ^Date.utc_today())

  defp timing(query, "ongoing") do
    today = Date.utc_today()
    where(query, [t], t.start_date <= ^today and (is_nil(t.end_date) or t.end_date >= ^today))
  end

  defp timing(query, "past"),
    do: where(query, [t], t.end_date < ^Date.utc_today())

  defp timing(query, "undated"),
    do: where(query, [t], is_nil(t.start_date))

  defp timing(query, _), do: query
end
