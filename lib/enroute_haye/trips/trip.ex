defmodule EnrouteHaye.Trips.Trip do
  use Ecto.Schema
  import Ecto.Changeset

  alias EnrouteHaye.Accounts.User
  alias EnrouteHaye.Schema.Event
  alias EnrouteHaye.Trips.{TripAccommodation, TripAudio, TripExpense, TripFood, TripStop, TripTransportSegment}

  schema "trips" do
    field :title, :string
    field :description, :string
    field :start_date, :date
    field :end_date, :date
    field :budget_estimate, :decimal
    field :status, :string, default: "draft"
    field :starting_province, :string
    field :starting_district, :string
    field :destination_province, :string
    field :destination_district, :string
    field :traveller_name, :string
    field :traveller_count, :integer, default: 1
    field :duration_days, :integer
    field :guest_token_hash, :binary, redact: true
    field :currency, :string, default: "ZMW"

    belongs_to :user, User
    belongs_to :selected_event, Event
    has_many :trip_stops, TripStop, on_replace: :delete
    has_many :transport_segments, TripTransportSegment, on_replace: :delete
    has_many :food_selections, TripFood, on_replace: :delete
    has_many :audio_selections, TripAudio, on_replace: :delete
    has_many :accommodation_selections, TripAccommodation, on_replace: :delete
    has_many :expenses, TripExpense, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [
      :title,
      :description,
      :start_date,
      :end_date,
      :budget_estimate,
      :status,
      :starting_province,
      :starting_district,
      :destination_province,
      :destination_district,
      :traveller_name,
      :traveller_count,
      :duration_days,
      :selected_event_id,
      :currency
    ])
    |> validate_length(:title, max: 160)
    |> validate_number(:traveller_count, greater_than: 0, less_than_or_equal_to: 100)
    |> validate_number(:duration_days, greater_than: 0, less_than_or_equal_to: 365)
    |> validate_number(:budget_estimate, greater_than_or_equal_to: 0)
    |> validate_inclusion(:status, ["draft", "submitted", "confirmed", "cancelled"])
    |> validate_date_order()
    |> foreign_key_constraint(:selected_event_id)
  end

  defp validate_date_order(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if start_date && end_date && Date.compare(end_date, start_date) == :lt do
      add_error(changeset, :end_date, "must be on or after the start date")
    else
      changeset
    end
  end
end
