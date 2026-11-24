defmodule EnrouteHaye.Schema.Site do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :name, :string
    field :description, :string
    field :status, :string
    field :location, :string
    field :latitude, :float
    field :longitude, :float
    field :category, :string
    field :image_url, :string
    # cost in $ to visit, 0 = free
    field :price, :integer, default: 0

    timestamps()
  end

  def changeset(site, attrs) do
    site
    |> cast(attrs, [
      :name,
      :description,
      :status,
      :location,
      :latitude,
      :longitude,
      :category,
      :image_url,
      :price
    ])
    |> validate_required([:name, :image_url])
    |> validate_number(:price, greater_than_or_equal_to: 0)
  end
end
