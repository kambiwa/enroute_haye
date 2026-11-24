defmodule EnrouteHaye.Trips.TripTransportSegment do
  use Ecto.Schema
  import Ecto.Changeset

  alias EnrouteHaye.Schema.{Airline, Road}
  alias EnrouteHaye.Trips.Trip

  schema "trip_transport_segments" do
    field :mode, :string
    field :order_index, :integer, default: 0
    field :estimated_cost, :decimal
    field :notes, :string
    belongs_to :trip, Trip
    belongs_to :road, Road
    belongs_to :airline, Airline
    timestamps(type: :utc_datetime)
  end

  def changeset(segment, attrs) do
    segment
    |> cast(attrs, [:trip_id, :mode, :order_index, :road_id, :airline_id, :estimated_cost, :notes])
    |> validate_required([:trip_id, :mode, :order_index])
    |> validate_inclusion(:mode, ["road", "bus", "air", "mixed", "private_vehicle", "other"])
    |> validate_number(:order_index, greater_than_or_equal_to: 0)
    |> validate_number(:estimated_cost, greater_than_or_equal_to: 0)
    |> validate_provider()
    |> foreign_key_constraint(:trip_id)
    |> foreign_key_constraint(:road_id)
    |> foreign_key_constraint(:airline_id)
  end

  defp validate_provider(changeset) do
    mode = get_field(changeset, :mode)
    road_id = get_field(changeset, :road_id)
    airline_id = get_field(changeset, :airline_id)

    cond do
      mode in ["road", "bus"] and is_nil(road_id) -> add_error(changeset, :road_id, "is required")
      mode == "air" and is_nil(airline_id) -> add_error(changeset, :airline_id, "is required")
      mode == "private_vehicle" and (road_id || airline_id) ->
        add_error(changeset, :mode, "cannot have a public transport provider")

      true -> changeset
    end
  end
end
