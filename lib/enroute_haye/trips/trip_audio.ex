defmodule EnrouteHaye.Trips.TripAudio do
  use Ecto.Schema
  import Ecto.Changeset

  alias EnrouteHaye.Schema.Audio
  alias EnrouteHaye.Trips.Trip

  schema "trip_audio_selections" do
    belongs_to :trip, Trip
    belongs_to :audio, Audio
    timestamps(type: :utc_datetime)
  end

  def changeset(selection, attrs) do
    selection
    |> cast(attrs, [:trip_id, :audio_id])
    |> validate_required([:trip_id, :audio_id])
    |> unique_constraint([:trip_id, :audio_id])
    |> foreign_key_constraint(:trip_id)
    |> foreign_key_constraint(:audio_id)
  end
end
