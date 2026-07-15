defmodule EnrouteHaye.Schema.Media do
  use Ecto.Schema
  import Ecto.Changeset

  schema "media" do
    field :title, :string
    field :media_type, :string
    field :author, :string
    field :category, :string
    field :description, :string
    field :location, :string
    field :file_path, :string
    field :minutes, :integer
    field :poster_path, :string

    timestamps()
  end

  @doc false
  def changeset(media, attrs) do
    media
    |> cast(attrs, [
      :title,
      :media_type,
      :author,
      :category,
      :description,
      :location,
      :file_path,
      :minutes,
      :poster_path
    ])
    |> validate_required([:title, :author, :category, :description, :location, :file_path])
  end
end
