defmodule EnrouteHaye.Trips.TripAccommodation do
  use Ecto.Schema
  import Ecto.Changeset

  alias EnrouteHaye.Schema.Accommodation
  alias EnrouteHaye.Trips.Trip

  schema "trip_accommodation_selections" do
    field :check_in, :date
    field :check_out, :date
    field :nightly_price_estimate, :decimal
    belongs_to :trip, Trip
    belongs_to :accommodation, Accommodation
    timestamps(type: :utc_datetime)
  end

  def changeset(selection, attrs) do
    selection
    |> cast(attrs, [:trip_id, :accommodation_id, :check_in, :check_out, :nightly_price_estimate])
    |> validate_required([:trip_id, :accommodation_id])
    |> validate_number(:nightly_price_estimate, greater_than_or_equal_to: 0)
    |> validate_dates()
    |> unique_constraint(:trip_id)
    |> foreign_key_constraint(:trip_id)
    |> foreign_key_constraint(:accommodation_id)
  end

  defp validate_dates(changeset) do
    check_in = get_field(changeset, :check_in)
    check_out = get_field(changeset, :check_out)

    if check_in && check_out && Date.compare(check_out, check_in) != :gt do
      add_error(changeset, :check_out, "must be after check-in")
    else
      changeset
    end
  end
end
