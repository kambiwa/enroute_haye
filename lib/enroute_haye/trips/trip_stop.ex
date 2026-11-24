defmodule EnrouteHaye.Trips.TripStop do
  use Ecto.Schema
  import Ecto.Changeset

  alias EnrouteHaye.Schema.Site
  alias EnrouteHaye.Trips.Trip

  schema "trip_stops" do
    field :day_number, :integer
    field :order_index, :integer
    field :notes, :string

    belongs_to :trip, Trip
    belongs_to :site, Site

    timestamps(type: :utc_datetime)
  end

  def changeset(stop, attrs) do
    stop
    |> cast(attrs, [:trip_id, :site_id, :day_number, :order_index, :notes])
    |> validate_required([:trip_id, :site_id, :order_index])
    |> validate_number(:day_number, greater_than: 0)
    |> validate_number(:order_index, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:trip_id)
    |> foreign_key_constraint(:site_id)
  end
end
