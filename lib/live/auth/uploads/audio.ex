defmodule EnrouteHayeWeb.Auth.Uploads.Audio do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Context.Media

  def mount(_params, _session, socket) do
    tracks = Media.list_tracks()

    socket =
      socket
      |> allow_upload(:audio, accept: ~w(.mp3 .wav), max_entries: 1, max_file_size: 20_000_000)
      |> assign(:tracks, tracks)
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

    Media.create_track(%{
      title: params["title"],
      artist: params["artist"],
      file_url: file_url
    })

    tracks = Media.list_tracks()

    socket =
      socket
      |> assign(:tracks, tracks)
      |> assign(:current_track, List.first(tracks))
      |> put_flash(:info, "Track uploaded successfully.")

    {:noreply, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :audio, ref)}
  end

  def render(assigns) do
    ~H"""


    <div class="upload-root">
      <div class="up-header">
        <h1>Audio Manager</h1>
        <span class="badge">Admin</span>
      </div>

      <div class="up-grid">

        <%!-- ── Upload Form Panel ── --%>
        <div class="up-panel">
          <div class="up-panel-header">
            <span class="dot"></span>
            New Track
          </div>
          <div class="up-panel-body">
            <form phx-submit="save" phx-change="validate">

              <div class="field">
                <label>Title</label>
                <input type="text" name="title" placeholder="Track title" required />
              </div>

              <div class="field">
                <label>Artist</label>
                <input type="text" name="artist" placeholder="Artist name" required />
              </div>

              <div class="field">
                <label>Audio File</label>
                <div class="drop-zone">
                  <.live_file_input upload={@uploads.audio} />
                  <span class="drop-icon">♫</span>
                  <p class="drop-label">
                    <strong>Click to browse</strong> or drag & drop<br/>
                    MP3 or WAV · max 20 MB
                  </p>
                </div>

                <%= for entry <- @uploads.audio.entries do %>
                  <div class="entry-row">
                    <span class="entry-name"><%= entry.client_name %></span>
                    <button
                      type="button"
                      class="entry-cancel"
                      phx-click="cancel-upload"
                      phx-value-ref={entry.ref}
                      aria-label="Cancel"
                    >✕</button>
                  </div>
                  <%= for err <- upload_errors(@uploads.audio, entry) do %>
                    <p class="entry-error"><%= error_to_string(err) %></p>
                  <% end %>
                <% end %>
              </div>

              <button
                type="submit"
                class="btn-upload"
                disabled={@uploads.audio.entries == []}
              >
                Upload Track
              </button>
            </form>
          </div>
        </div>

        <%!-- ── Track Library Panel ── --%>
        <div class="up-panel">
          <div class="up-panel-header">
            <span class="dot"></span>
            Library · <%= length(@tracks) %> tracks
          </div>
          <div class="up-panel-body">
            <%= if @tracks == [] do %>
              <div class="empty-state">No tracks uploaded yet</div>
            <% else %>
              <ul class="track-list">
                <%= for {track, i} <- Enum.with_index(@tracks, 1) do %>
                  <li class="track-item">
                    <span class="track-num"><%= i %></span>
                    <div class="track-info">
                      <div class="track-title"><%= track.title %></div>
                      <div class="track-artist"><%= track.artist %></div>
                    </div>
                    <button
                      class="btn-play"
                      phx-click="play"
                      phx-value-url={track.file_url}
                      title="Play"
                    >▶</button>
                  </li>
                <% end %>
              </ul>
            <% end %>
          </div>
        </div>

      </div>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "File exceeds 20 MB limit"
  defp error_to_string(:not_accepted), do: "Only .mp3 and .wav files are accepted"
  defp error_to_string(:too_many_files), do: "Only one file at a time"
  defp error_to_string(err), do: "Upload error: #{inspect(err)}"
end
