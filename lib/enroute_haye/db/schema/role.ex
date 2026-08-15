defmodule EnrouteHaye.Schema.Role do
  use Ecto.Schema
  import Ecto.Changeset

    schema "Role" do
      field :name, :string
      field :description, :string
      field :status, :string

      timestamps()
    end

    def changeset(role, attrs) do
      role
      |> cast(attrs, [:name, :description, :status])
      |> validate_required([:name,])
    end

end
