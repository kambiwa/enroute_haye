defmodule EnrouteHaye.Schema.Audio do
  use Ecto.Schema
  import Ecto.Changeset


  schema "audio" do
    field :title, :string
    field :artist, :string
    field :description, :string
    field :file_url, :string
    field :duration, :integer
    field :cover_image, :string
    field :category, :string
    timestamps()
  end

  @doc false
  def changeset(audio, attrs) do
    audio
    |> cast(attrs, [:title, :artist, :description, :file_url, :duration, :cover_image])
    |> validate_required([:title, :artist, :file_url, :duration])
  end
end
