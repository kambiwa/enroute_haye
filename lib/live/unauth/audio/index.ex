defmodule EnrouteHayeWeb.Auth.Audio.Index do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Context.CxtAudio

  def mount(_params, _session, socket) do
    tracks = CxtAudio.list_audios(%{"page_size" => 100}).entries

    socket =
      socket
      |> allow_upload(:audio, accept: ~w(.mp3 .wav), max_entries: 1, max_file_size: 20_000_000)
      |> assign(:tracks, tracks)
      # ← pick first track
      |> assign(:current_track, List.first(tracks))

    {:ok, socket}
  end

  def handle_event("play", %{"url" => url}, socket) do
    {:noreply, push_event(socket, "play_track", %{url: url})}
  end

  def handle_event("save", params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :audio, fn %{path: path}, entry ->
        dest =
          Path.join([
            :code.priv_dir(:enroute_haye),
            "static/uploads/audio",
            entry.client_name
          ])

        File.cp!(path, dest)
        {:ok, "/uploads/audio/#{entry.client_name}"}
      end)

    file_url = List.first(uploaded_files)

    CxtAudio.create_audio(%{
      title: params["title"],
      artist: params["artist"],
      file_url: file_url,
      duration: 0
    })

    tracks = CxtAudio.list_audios(%{"page_size" => 100}).entries

    socket =
      socket
      |> assign(:tracks, tracks)
      |> assign(:current_track, List.first(tracks))

    {:noreply, socket}
  end
end
