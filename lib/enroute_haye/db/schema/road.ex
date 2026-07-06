defmodule EnrouteHaye.Schema.Road do
  use Ecto.Schema

  import Ecto.Changeset

  schema "roads" do
    field :operator,         :string
    field :route,            :string
    field :departure_point,  :string
    field :arrival_point,    :string
    field :departure_time,   :naive_datetime
    field :arrival_time,     :naive_datetime
    field :price,            :decimal
    field :operator_contact, :string

    timestamps()
  end

  @required_fields ~w(operator)a
  @optional_fields ~w(route departure_point arrival_point departure_time arrival_time price operator_contact)a

  @doc false
  def changeset(road, attrs \\ %{}) do
    road
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
