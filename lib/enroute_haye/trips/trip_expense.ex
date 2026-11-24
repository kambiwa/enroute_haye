defmodule EnrouteHaye.Trips.TripExpense do
  use Ecto.Schema
  import Ecto.Changeset

  alias EnrouteHaye.Trips.Trip

  @categories ~w(transport accommodation food entrance_fee activity other)

  schema "trip_expenses" do
    field :category, :string
    field :title, :string
    field :amount, :decimal
    field :currency, :string, default: "ZMW"
    field :price_type, :string, default: "estimated"
    field :notes, :string
    belongs_to :trip, Trip
    timestamps(type: :utc_datetime)
  end

  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:trip_id, :category, :title, :amount, :currency, :price_type, :notes])
    |> validate_required([:trip_id, :category, :title, :amount, :currency, :price_type])
    |> validate_inclusion(:category, @categories)
    |> validate_inclusion(:price_type, ["estimated", "recorded", "confirmed"])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> validate_length(:currency, is: 3)
    |> foreign_key_constraint(:trip_id)
  end
end
