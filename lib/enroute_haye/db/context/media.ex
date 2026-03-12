defmodule EnrouteHaye.Context.Media do
  alias EnrouteHaye.Repo
  alias EnrouteHaye.Schema.Audio

  def create_track(attrs) do
    %Audio{}
    |> Audio.changeset(attrs)
    |> Repo.insert()
  end

  def list_tracks do
    Repo.all(Audio)
  end

  def get_track(id) do
    Repo.get(Audio, id)
  end
  
end
