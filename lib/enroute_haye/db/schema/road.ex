defmodule EnrouteHaye.Schema.Road do
      Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      schema "roads" do
        field :operator, :string
        field :route, :string
        field :departure_point, :text
        field :arrival_point, :text
        field :departure_time, :naive_datetime
        field :arrival_time, :naive_datetime
        field :price, :decimal
        field :operator_contact, :string

        timestamps(type: :utc_datetime)
      end


  @doc false
  def changeset(road, attrs) do
    road
    |> cast(attrs, [:operator, :route, :departure_point, :arrival_point, :departure_time, :arrival_time, :price, :operator_contact])
    |> validate_required([:operator])
  end
end
