defmodule EnrouteHaye.Schema.Accommodation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accommodations" do
    field :name, :string
    field :description, :string
    field :location, :string
    field :latitude, :float
    field :longitude, :float
    field :price_per_night, :decimal
    field :rating, :float
    field :contact_email, :string
    field :contact_phone, :string
    field :image_url, :string
    has_many :trip_selections, EnrouteHaye.Trips.TripAccommodation
    timestamps(type: :utc_datetime)
  end

  def changeset(accommodation, attrs) do
    accommodation
    |> cast(attrs, [
      :name,
      :description,
      :location,
      :latitude,
      :longitude,
      :price_per_night,
      :rating,
      :contact_email,
      :contact_phone,
      :image_url
    ])
    |> validate_required([:name])
    |> validate_number(:price_per_night, greater_than_or_equal_to: 0)
  end
end
