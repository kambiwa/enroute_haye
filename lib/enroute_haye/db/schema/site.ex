defmodule EnrouteHaye.Schema.Site do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :name, :string
    field :description, :string
    field :status, :string
    field :location, :string
    field :category, :string
    field :image_url, :string

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name, :description, :status, :location, :category, :image_url])
    |> validate_required([:name, :image_url])
  end
end
