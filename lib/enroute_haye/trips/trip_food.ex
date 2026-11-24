defmodule EnrouteHaye.Trips.TripFood do
  use Ecto.Schema
  import Ecto.Changeset

  alias EnrouteHaye.Schema.Food
  alias EnrouteHaye.Trips.Trip

  schema "trip_food_selections" do
    field :quantity, :integer, default: 1
    field :unit_price_estimate, :decimal
    belongs_to :trip, Trip
    belongs_to :food, Food
    timestamps(type: :utc_datetime)
  end

  def changeset(selection, attrs) do
    selection
    |> cast(attrs, [:trip_id, :food_id, :quantity, :unit_price_estimate])
    |> validate_required([:trip_id, :food_id, :quantity])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:unit_price_estimate, greater_than_or_equal_to: 0)
    |> unique_constraint([:trip_id, :food_id])
    |> foreign_key_constraint(:trip_id)
    |> foreign_key_constraint(:food_id)
  end
end
