defmodule EnrouteHaye.Schema.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
      field :title, :string
      field :description, :string
      field :start_date, :naive_datetime
      field :end_date, :naive_datetime
      field :location, :string
      field :latitude, :float
      field :longitude, :float
      field :image_url, :string

    timestamps()
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:title, :description, :start_date, :end_date, :location, :latitude, :longitude, :image_url])
    |> validate_required([:title, :start_date, :end_date])
  end
end
