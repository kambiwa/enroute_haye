defmodule EnrouteHaye.Context.Media do
  alias EnrouteHaye.Repo
  alias EnrouteHaye.Schema.Audio


#   EnrouteHaye.Context.Media.create_track(%{
#   title: "Test Song",
#   artist: "Test Artist",
#   description: "Sample audio track",
#   file_url: "/uploads/test.mp3",
#   duration: 180,
#   cover_image: "/uploads/test.jpg"
# })

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
