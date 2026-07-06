defmodule EnrouteHaye.Schema.Airline do
      use Ecto.Schema

      import Ecto.Changeset
      import Ecto.Query

      schema "airline" do
        field :airline_name, :string
        field :flight_number, :string
        field :departure_district, :string
        field :arrival, :string
        field :departure_time, :naive_datetime
        field :arrival_time, :naive_datetime
        field :price, :decimal
        field :airline_contact, :string

        timestamps()
      end

       @doc false
      def changeset(airline, attrs) do
        airline
        |> cast(attrs, [:airline_name, :flight_number, :departure_district, :arrival, :departure_time, :arrival_time, :price, :airline_contact])
        |> validate_required([:airline_name])
      end
end
