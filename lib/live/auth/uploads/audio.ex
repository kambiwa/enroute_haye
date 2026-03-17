defmodule EnrouteHayeWeb.Auth.Uploads.Audio do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Context.Media

  def mount(_params, _session, socket) do

    upload_dir = Path.join([:code.priv_dir(:enroute_haye), "static/uploads/audio"])
    File.mkdir_p!(upload_dir)

    tracks = Media.list_tracks()

    socket =
      socket
      |> allow_upload(:audio, accept: ~w(.mp3 .wav), max_entries: 1, max_file_size: 20_000_000)
      |> assign(:tracks, tracks)
      |> assign(:current_track, List.first(tracks))

    {:ok, socket}
  end

  # def handle_event("play", %{"url" => url}, socket) do
  #   {:noreply, push_event(socket, "play_track", %{url: url})}
  # end

  def handle_event("play", %{"url" => url}, socket) do
    IO.inspect(socket, label: "")
  {:noreply, assign(socket, current_track: url)}
  end

  def handle_event("save", params, socket) do
  IO.inspect(socket.assigns.uploads.audio.entries, label: "UPLOAD ENTRIES")
  # Guard: no entries uploaded
  if socket.assigns.uploads.audio.entries == [] do
    {:noreply, put_flash(socket, :error, "Please select an audio file.")}
  else
    uploaded_files =
  consume_uploaded_entries(socket, :audio, fn %{path: path}, entry ->
    dest =
      Path.join([
        :code.priv_dir(:enroute_haye),
        "static/uploads/audio",
        entry.client_name
      ])

    case File.cp(path, dest) do
      :ok ->
        url = "/uploads/audio/#{entry.client_name}"
        {:ok, url}   # ← MUST be the last thing returned

      {:error, posix_error} ->
        Logger.error("Failed to copy uploaded file: #{inspect(posix_error)}")
        {:error, "Failed to save file on disk"}
    end
  end)

    case uploaded_files do
      [] ->
        {:noreply, put_flash(socket, :error, "File upload failed. Please try again.")}

      [file_url | _] ->
        case Media.create_track(%{
          title: params["title"],
          artist: params["artist"],
          file_url: file_url
        }) do
          {:ok, _track} ->
            tracks = Media.list_tracks()

            socket =
              socket
              |> assign(:tracks, tracks)
              |> assign(:current_track, List.first(tracks))
              |> put_flash(:info, "Track uploaded successfully.")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, put_flash(socket, :error, "Failed to save track: #{inspect(changeset.errors)}")}
        end
    end
  end
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
                <div class="drop-zone" phx-drop-target={@uploads.audio.ref}>
                  <.live_file_input upload={@uploads.audio} />
                  <span class="drop-icon">♫</span>
                  <p class="drop-label">
                    <strong>Click to browse</strong> or drag & drop<br/>
                    MP3 or WAV · max 20 MB
                  </p>
                </div>

                <%= for entry <- @uploads.audio.entries do %>
                  <div class="entry-row">
                    <progress value={entry.progress} max="100"></progress>
                       <span><%= entry.progress %>%</span>
                    <button
                      type="button"
                      phx-click="cancel-upload"
                      phx-value-ref={entry.ref}>
                      ✕
                    </button>
                  </div>
                  <%= for err <- upload_errors(@uploads.audio, entry) do %>
                    <p class="entry-error"><%= error_to_string(err) %></p>
                  <% end %>
                <% end %>
              </div>

            <button
              type="submit"
              class="btn-upload"
              phx-disable-with="Uploading..."
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
