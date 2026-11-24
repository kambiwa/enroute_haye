defmodule EnrouteHaye.Schema.Department do
  use Ecto.Schema
  import Ecto.Changeset

  schema "department" do
    field :name, :string
    field :description, :string
    field :status, :string

    timestamps()
  end

  def changeset(department, attrs) do
    department
    |> cast(attrs, [:name, :description, :status])
    |> validate_required([:name])
  end
end
