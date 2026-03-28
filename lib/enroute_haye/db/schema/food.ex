defmodule EnrouteHaye.Schema.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "foods" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :image_url, :string

    timestamps()
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name, :description, :image_url, :price])
    |> validate_required([:name])
  end
end
