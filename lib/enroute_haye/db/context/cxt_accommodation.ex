defmodule EnrouteHaye.Context.CxtAccommodation do
  import Ecto.Query
  alias EnrouteHaye.Repo
  alias EnrouteHaye.Schema.Accommodation

  def list_accommodations(filters \\ %{}) do
    query = from(a in Accommodation, order_by: [asc: a.name])

    query =
      if location = filters[:location] || filters["location"],
        do: where(query, [a], ilike(a.location, ^"%#{location}%")),
        else: query

    Repo.all(query)
  end
end
